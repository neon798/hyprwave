#!/usr/bin/env bash
# Theme pack structural consistency under build_files/usr/share/hyprwave/themes/*
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

CHECK_ID="themes"
THEMES_ROOT="build_files/usr/share/hyprwave/themes"

echo "== check-themes (repo: $ROOT) =="

if [[ ! -d "$THEMES_ROOT" ]]; then
  qa_missing_artifact "${CHECK_ID}.root" "$THEMES_ROOT" "theme store missing"
  qa_print_summary "check-themes"
  qa_exit_code
  exit $?
fi

# Expected per-theme components (paths relative to theme dir).
# Wallpaper: any image under wallpapers/ OR documented exception file.
REQUIRED_FILES=(
  "hypr/looknfeel.conf"
  "waybar/style.css"
  "walker/style.css"
  "ghostty/config"
)

# Themes that may intentionally omit a component: list path patterns in
# planning/qa/theme-exceptions.list (optional, one "theme:component" per line).
EXCEPTIONS_FILE="planning/qa/theme-exceptions.list"
declare -A EXCEPTIONS=()
if [[ -f "$EXCEPTIONS_FILE" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    EXCEPTIONS["$line"]=1
  done <"$EXCEPTIONS_FILE"
  qa_pass "${CHECK_ID}.exceptions-file" "loaded $EXCEPTIONS_FILE"
fi

is_excepted() {
  local theme="$1"
  local component="$2"
  [[ -n "${EXCEPTIONS["${theme}:${component}"]:-}" ]]
}

theme_count=0
shopt -s nullglob
for theme_dir in "$THEMES_ROOT"/*/; do
  [[ -d "$theme_dir" ]] || continue
  theme="$(basename "$theme_dir")"
  theme_count=$((theme_count + 1))
  local_fail=0

  for rel in "${REQUIRED_FILES[@]}"; do
    if is_excepted "$theme" "$rel"; then
      qa_warn "${CHECK_ID}.${theme}" "exception: ${theme} omits ${rel}"
      continue
    fi
    if [[ -f "${theme_dir}${rel}" ]]; then
      :
    else
      qa_fail "${CHECK_ID}.${theme}" "missing ${rel}"
      local_fail=1
    fi
  done

  # Wallpaper: at least one image, or exception "wallpapers"
  if is_excepted "$theme" "wallpapers"; then
    qa_warn "${CHECK_ID}.${theme}" "exception: ${theme} omits wallpapers"
  else
    mapfile -t walls < <(find "${theme_dir}wallpapers" -type f \
      \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
      2>/dev/null || true)
    if [[ ${#walls[@]} -gt 0 ]]; then
      :
    else
      qa_fail "${CHECK_ID}.${theme}" "no wallpaper images under wallpapers/"
      local_fail=1
    fi
  fi

  if [[ "$local_fail" -eq 0 ]]; then
    qa_pass "${CHECK_ID}.${theme}" "components OK"
  fi
done
shopt -u nullglob

if [[ "$theme_count" -eq 0 ]]; then
  qa_fail "${CHECK_ID}.count" "no themes found under $THEMES_ROOT"
else
  qa_pass "${CHECK_ID}.count" "${theme_count} theme(s) scanned"
fi

qa_print_summary "check-themes"
qa_exit_code
