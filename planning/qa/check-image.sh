#!/usr/bin/env bash
# Container image smoke: inspect local hyprwave (and optional cosmic) images.
# Missing images → SKIP (not FAIL) so host trees stay green without a build.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

CHECK_ID="image"
HYPRWAVE_IMAGE="${HYPRWAVE_IMAGE:-localhost/hyprwave:latest}"
HYPRWAVE_COSMIC_IMAGE="${HYPRWAVE_COSMIC_IMAGE:-localhost/hyprwave-cosmic:latest}"
FORCE_COSMIC=0

usage() {
  cat <<'EOF'
Usage: bash planning/qa/check-image.sh [options]

Options:
  --cosmic          Also require/check the cosmic image (still SKIP if missing)
  -h, --help        Show this help

Environment:
  HYPRWAVE_IMAGE          Default: localhost/hyprwave:latest
  HYPRWAVE_COSMIC_IMAGE   Default: localhost/hyprwave-cosmic:latest
                          Cosmic checks run when image exists, or when --cosmic is set
                          (missing → SKIP either way).
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cosmic)
      FORCE_COSMIC=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

echo "== check-image (repo: $ROOT) =="
echo "  HYPRWAVE_IMAGE=${HYPRWAVE_IMAGE}"
echo "  HYPRWAVE_COSMIC_IMAGE=${HYPRWAVE_COSMIC_IMAGE}"

if ! command -v podman >/dev/null 2>&1; then
  qa_skip "${CHECK_ID}.podman" "podman not on PATH — cannot inspect images"
  qa_print_summary "check-image"
  qa_exit_code
  exit $?
fi
qa_pass "${CHECK_ID}.podman" "podman available"

image_exists() {
  local img="$1"
  podman image exists "$img" 2>/dev/null
}

# Run a scriptlet inside the image; stdout is the body, exit is container exit.
# Usage: image_run <image> <bash-script>
image_run() {
  local img="$1"
  local script="$2"
  podman run --rm --entrypoint bash "$img" -lc "$script"
}

# ---------- Hyprland variant ----------
if ! image_exists "$HYPRWAVE_IMAGE"; then
  qa_skip "${CHECK_ID}.hyprland.present" \
    "image missing: ${HYPRWAVE_IMAGE} (build with just build; not a FAIL)"
else
  qa_pass "${CHECK_ID}.hyprland.present" "found ${HYPRWAVE_IMAGE}"

  # Single scriptlet returns KEY=value lines for parsing.
  # shellcheck disable=SC2016
  out="$(image_run "$HYPRWAVE_IMAGE" '
set +e
fail=0
report() { printf "%s=%s\n" "$1" "$2"; }

# assistant version
av="$(hyprwave-assistant --version 2>/dev/null || true)"
if [[ -z "$av" ]]; then av="$(hyprwave-assistant version 2>/dev/null || true)"; fi
if [[ -n "$av" ]]; then report assistant_version "ok:$av"; else report assistant_version fail; fail=1; fi

for bin in hyprwave-theme walker hyprpaper; do
  if command -v "$bin" >/dev/null 2>&1; then
    report "bin_$bin" ok
  else
    report "bin_$bin" fail
    fail=1
  fi
done

theme_n="$(ls -1 /usr/share/hyprwave/themes 2>/dev/null | wc -l | tr -d " ")"
if [[ "${theme_n:-0}" -ge 11 ]]; then
  report themes "ok:$theme_n"
else
  report themes "fail:$theme_n"
  fail=1
fi

if [[ -f /usr/share/hyprwave/assistant/catalog.toml ]]; then
  report catalog ok
else
  report catalog fail
  fail=1
fi

if [[ -f /usr/share/hyprwave/duress/ENABLE.md ]]; then
  report enable_md ok
else
  report enable_md fail
  fail=1
fi

# no pam_duress in /etc/pam.d
if grep -Rqs pam_duress /etc/pam.d 2>/dev/null; then
  report pam_duress fail
  fail=1
else
  report pam_duress ok
fi

# sddm enabled (hyprland variant)
sddm_state="$(systemctl is-enabled sddm 2>/dev/null || true)"
if [[ "$sddm_state" == "enabled" ]]; then
  report sddm ok
else
  # also accept display-manager symlink → sddm
  dm="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
  if [[ "$dm" == *sddm* ]]; then
    report sddm "ok:dm=$dm"
  else
    report sddm "fail:${sddm_state:-none}"
    fail=1
  fi
fi

# no wofi/swaybg as installed defaults
bad=0
for bin in wofi swaybg; do
  if command -v "$bin" >/dev/null 2>&1; then
    bad=1
  fi
  if [[ -e "/usr/bin/$bin" || -e "/usr/sbin/$bin" ]]; then
    bad=1
  fi
done
if [[ "$bad" -eq 0 ]]; then
  report no_wofi_swaybg ok
else
  report no_wofi_swaybg fail
  fail=1
fi

report overall "$fail"
exit 0
')"

  parse_kv() {
    local key="$1"
    printf '%s\n' "$out" | grep -E "^${key}=" | head -1 | cut -d= -f2-
  }

  av="$(parse_kv assistant_version)"
  if [[ "$av" == ok:* ]]; then
    qa_pass "${CHECK_ID}.hyprland.assistant" "hyprwave-assistant ${av#ok:}"
  else
    qa_fail "${CHECK_ID}.hyprland.assistant" "hyprwave-assistant --version failed in image"
  fi

  for bin in hyprwave-theme walker hyprpaper; do
    v="$(parse_kv "bin_${bin}")"
    if [[ "$v" == ok ]]; then
      qa_pass "${CHECK_ID}.hyprland.bin.${bin}" "${bin} present"
    else
      qa_fail "${CHECK_ID}.hyprland.bin.${bin}" "${bin} missing in image PATH"
    fi
  done

  th="$(parse_kv themes)"
  if [[ "$th" == ok:* ]]; then
    qa_pass "${CHECK_ID}.hyprland.themes" "themes count ${th#ok:} (≥11)"
  else
    qa_fail "${CHECK_ID}.hyprland.themes" "expected ≥11 themes under /usr/share/hyprwave/themes (got ${th#fail:})"
  fi

  for key in catalog enable_md pam_duress sddm no_wofi_swaybg; do
    v="$(parse_kv "$key")"
    case "$key" in
      catalog)
        if [[ "$v" == ok ]]; then qa_pass "${CHECK_ID}.hyprland.catalog" "catalog.toml present"
        else qa_fail "${CHECK_ID}.hyprland.catalog" "missing /usr/share/hyprwave/assistant/catalog.toml"; fi
        ;;
      enable_md)
        if [[ "$v" == ok ]]; then qa_pass "${CHECK_ID}.hyprland.enable_md" "ENABLE.md present"
        else qa_fail "${CHECK_ID}.hyprland.enable_md" "missing /usr/share/hyprwave/duress/ENABLE.md"; fi
        ;;
      pam_duress)
        if [[ "$v" == ok ]]; then qa_pass "${CHECK_ID}.hyprland.pam" "no pam_duress in /etc/pam.d"
        else qa_fail "${CHECK_ID}.hyprland.pam" "pam_duress found in /etc/pam.d (must be OFF)"; fi
        ;;
      sddm)
        if [[ "$v" == ok || "$v" == ok:* ]]; then qa_pass "${CHECK_ID}.hyprland.sddm" "sddm enabled (${v})"
        else qa_fail "${CHECK_ID}.hyprland.sddm" "sddm not enabled (${v})"; fi
        ;;
      no_wofi_swaybg)
        if [[ "$v" == ok ]]; then qa_pass "${CHECK_ID}.hyprland.no-legacy" "no wofi/swaybg binaries"
        else qa_fail "${CHECK_ID}.hyprland.no-legacy" "wofi or swaybg still present in image"; fi
        ;;
    esac
  done
fi

# ---------- COSMIC variant (optional / skip-if-missing) ----------
check_cosmic=0
if image_exists "$HYPRWAVE_COSMIC_IMAGE"; then
  check_cosmic=1
elif [[ "$FORCE_COSMIC" -eq 1 ]]; then
  qa_skip "${CHECK_ID}.cosmic.present" \
    "image missing: ${HYPRWAVE_COSMIC_IMAGE} (--cosmic requested; not a FAIL)"
else
  qa_skip "${CHECK_ID}.cosmic.present" \
    "image missing: ${HYPRWAVE_COSMIC_IMAGE} (optional; just build-cosmic)"
fi

if [[ "$check_cosmic" -eq 1 ]]; then
  qa_pass "${CHECK_ID}.cosmic.present" "found ${HYPRWAVE_COSMIC_IMAGE}"

  # shellcheck disable=SC2016
  cout="$(image_run "$HYPRWAVE_COSMIC_IMAGE" '
set +e
report() { printf "%s=%s\n" "$1" "$2"; }

if command -v cosmic-greeter >/dev/null 2>&1 || [[ -x /usr/bin/cosmic-greeter || -x /usr/sbin/cosmic-greeter ]]; then
  report greeter ok
else
  report greeter fail
fi

# sddm not required — prefer cosmic-greeter as DM when present
dm="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
cg="$(systemctl is-enabled cosmic-greeter 2>/dev/null || true)"
if [[ "$cg" == "enabled" || "$dm" == *cosmic-greeter* ]]; then
  report greeter_enabled "ok:${cg:-dm}"
else
  report greeter_enabled "warn:${cg:-none};dm=${dm:-none}"
fi

# no cosmic-store package/binary as default store
if command -v cosmic-store >/dev/null 2>&1 || [[ -e /usr/bin/cosmic-store || -e /usr/sbin/cosmic-store ]]; then
  report no_cosmic_store fail
elif rpm -q cosmic-store >/dev/null 2>&1; then
  report no_cosmic_store fail
else
  report no_cosmic_store ok
fi

if command -v flatarcade >/dev/null 2>&1 || [[ -e /usr/bin/flatarcade || -e /usr/sbin/flatarcade ]]; then
  report flatarcade ok
else
  report flatarcade fail
fi

if command -v hyprwave-theme >/dev/null 2>&1; then
  report theme_tool ok
else
  report theme_tool fail
fi

exit 0
')"

  cparse() {
    local key="$1"
    printf '%s\n' "$cout" | grep -E "^${key}=" | head -1 | cut -d= -f2-
  }

  v="$(cparse greeter)"
  if [[ "$v" == ok ]]; then qa_pass "${CHECK_ID}.cosmic.greeter" "cosmic-greeter present"
  else qa_fail "${CHECK_ID}.cosmic.greeter" "cosmic-greeter missing"; fi

  v="$(cparse greeter_enabled)"
  if [[ "$v" == ok || "$v" == ok:* ]]; then
    qa_pass "${CHECK_ID}.cosmic.greeter-enabled" "cosmic-greeter enabled (${v})"
  else
    qa_warn "${CHECK_ID}.cosmic.greeter-enabled" "could not confirm cosmic-greeter enabled (${v})"
  fi

  v="$(cparse no_cosmic_store)"
  if [[ "$v" == ok ]]; then qa_pass "${CHECK_ID}.cosmic.no-store" "cosmic-store not installed"
  else qa_fail "${CHECK_ID}.cosmic.no-store" "cosmic-store present (expect FlatArcade, not store)"; fi

  v="$(cparse flatarcade)"
  if [[ "$v" == ok ]]; then qa_pass "${CHECK_ID}.cosmic.flatarcade" "flatarcade present"
  else qa_fail "${CHECK_ID}.cosmic.flatarcade" "flatarcade missing"; fi

  v="$(cparse theme_tool)"
  if [[ "$v" == ok ]]; then qa_pass "${CHECK_ID}.cosmic.theme-tool" "hyprwave-theme present"
  else qa_warn "${CHECK_ID}.cosmic.theme-tool" "hyprwave-theme missing on cosmic image"; fi
fi

qa_print_summary "check-image"
qa_exit_code
