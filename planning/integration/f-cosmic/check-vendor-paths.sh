#!/usr/bin/env bash
# Repo-side sanity checks for COSMIC vendor defaults + theme-store cosmic packs.
# Run from anywhere; resolves repo root from this script path.
# Exit 0 = all checks pass; non-zero = failures printed on stderr.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
COSMIC="${ROOT}/build_files/usr/share/cosmic"
THEMES="${ROOT}/build_files/usr/share/hyprwave/themes"
WP_SRC="${ROOT}/build_files/usr/share/hyprwave/wallpapers/default.png"
BG_KEY="${COSMIC}/com.system76.CosmicBackground/v1/all"
FAV_KEY="${COSMIC}/com.system76.CosmicAppList/v1/favorites"
MODE_KEY="${COSMIC}/com.system76.CosmicTheme.Mode/v1/is_dark"

EXPECTED_DARK=30
EXPECTED_BUILDER=16
fail=0

err() { echo "FAIL: $*" >&2; fail=1; }
ok()  { echo "OK:   $*"; }

echo "== COSMIC vendor + theme path check =="
echo "ROOT=$ROOT"

# --- Vendor wallpaper source ---
if [[ -f "$WP_SRC" ]]; then
  ok "wallpaper source exists ($WP_SRC)"
  if file "$WP_SRC" 2>/dev/null | grep -qi 'PNG\|JPEG\|image'; then
    ok "wallpaper source is an image ($(file -b "$WP_SRC" | cut -c1-60))"
  else
    err "wallpaper source is not a recognized image: $(file -b "$WP_SRC" 2>/dev/null || true)"
  fi
else
  err "missing wallpaper source: $WP_SRC"
fi

# --- CosmicBackground path string ---
if [[ -f "$BG_KEY" ]]; then
  if grep -q '/usr/share/backgrounds/hyprwave/default.png' "$BG_KEY"; then
    ok "CosmicBackground points at /usr/share/backgrounds/hyprwave/default.png"
  else
    err "CosmicBackground path unexpected: $(tr -d '\n' <"$BG_KEY" | head -c 200)"
  fi
else
  err "missing $BG_KEY"
fi

# --- Favorites ---
if [[ -f "$FAV_KEY" ]]; then
  # Count non-empty quoted desktop IDs
  ids=$(grep -oE '"[^"]+"' "$FAV_KEY" | wc -l | tr -d ' ')
  if [[ "${ids:-0}" -ge 1 ]]; then
    ok "favorites has $ids desktop ID(s)"
  else
    err "favorites empty or unparseable"
  fi
  for need in neonwolf com.mitchellh.ghostty com.system76.CosmicFiles com.system76.CosmicSettings; do
    if grep -q "\"$need\"" "$FAV_KEY"; then
      ok "favorites includes $need"
    else
      err "favorites missing $need"
    fi
  done
else
  err "missing $FAV_KEY"
fi

# --- Mode ---
if [[ -f "$MODE_KEY" ]]; then
  mode=$(tr -d '[:space:]' <"$MODE_KEY")
  if [[ "$mode" == "true" ]]; then
    ok "Mode is_dark=true"
  else
    err "Mode is_dark expected true, got: $mode"
  fi
else
  err "missing Mode is_dark at $MODE_KEY"
fi

# --- Vendor Dark / Builder presence ---
vd=$(find "${COSMIC}/com.system76.CosmicTheme.Dark/v1" -type f 2>/dev/null | wc -l | tr -d ' ')
vb=$(find "${COSMIC}/com.system76.CosmicTheme.Dark.Builder/v1" -type f 2>/dev/null | wc -l | tr -d ' ')
[[ "$vd" -eq "$EXPECTED_DARK" ]] && ok "vendor Dark has $vd keys" || err "vendor Dark keys=$vd want $EXPECTED_DARK"
[[ "$vb" -eq "$EXPECTED_BUILDER" ]] && ok "vendor Builder has $vb keys" || err "vendor Builder keys=$vb want $EXPECTED_BUILDER"

# --- Theme packs ---
theme_count=0
if [[ ! -d "$THEMES" ]]; then
  err "missing themes dir $THEMES"
else
  for tdir in "$THEMES"/*/; do
    [[ -d "$tdir" ]] || continue
    name=$(basename "$tdir")
    theme_count=$((theme_count + 1))
    cfg="${tdir}cosmic/config"
    if [[ ! -d "$cfg" ]]; then
      err "theme $name: no cosmic/config/"
      continue
    fi
    d=$(find "${cfg}/com.system76.CosmicTheme.Dark/v1" -type f 2>/dev/null | wc -l | tr -d ' ')
    b=$(find "${cfg}/com.system76.CosmicTheme.Dark.Builder/v1" -type f 2>/dev/null | wc -l | tr -d ' ')
    [[ "$d" -eq "$EXPECTED_DARK" ]] || err "theme $name: Dark keys=$d want $EXPECTED_DARK"
    [[ "$b" -eq "$EXPECTED_BUILDER" ]] || err "theme $name: Builder keys=$b want $EXPECTED_BUILDER"
    if [[ -f "${cfg}/com.system76.CosmicTheme.Dark/v1/is_dark" ]]; then
      id=$(tr -d '[:space:]' <"${cfg}/com.system76.CosmicTheme.Dark/v1/is_dark")
      [[ "$id" == "true" ]] || err "theme $name: is_dark=$id"
    else
      err "theme $name: missing is_dark"
    fi
    # Wallpaper pick (mirrors hyprwave-theme preference: *2560x1440.jpg then default.png)
    base="${tdir}wallpapers"
    picked=""
    if compgen -G "${base}/wallpaper*-2560x1440.jpg" >/dev/null 2>&1; then
      for f in "${base}"/wallpaper*-2560x1440.jpg; do
        if [[ -r "$f" ]]; then picked="$f"; break; fi
      done
    elif [[ -r "${base}/default.png" ]]; then
      picked="${base}/default.png"
    fi
    if [[ -n "$picked" && -r "$picked" ]]; then
      ok "theme $name: Dark=$d Builder=$b wallpaper=$(basename "$picked")"
    else
      err "theme $name: no resolvable wallpaper under wallpapers/"
    fi
  done
  [[ "$theme_count" -ge 1 ]] && ok "scanned $theme_count theme pack(s)" || err "no theme packs found"
fi

echo "== done (fail=$fail) =="
exit "$fail"
