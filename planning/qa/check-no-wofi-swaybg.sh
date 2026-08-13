#!/usr/bin/env bash
# Fail if skel (or live theme-switch paths) still reference removed Wofi/swaybg stack.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

CHECK_ID="no-wofi-swaybg"
echo "== check-no-wofi-swaybg (repo: $ROOT) =="

# Paths that must not reintroduce the old stack
SEARCH_ROOTS=(
  "build_files/etc/skel"
  "build_files/usr/share/hyprwave"
  "build_files/usr/bin"
)

# Match whole words / common invocation forms; avoid matching unrelated strings
# like "wofifoo". Case-insensitive.
PATTERN='(^|[^[:alnum:]_-])(wofi|swaybg)([^[:alnum:]_-]|$)'

any_root=0
for root in "${SEARCH_ROOTS[@]}"; do
  if [[ -e "$root" ]]; then
    any_root=1
  fi
done

if [[ "$any_root" -eq 0 ]]; then
  qa_missing_artifact "${CHECK_ID}.roots" "skel/theme paths" "build_files tree incomplete"
  qa_print_summary "check-no-wofi-swaybg"
  qa_exit_code
  exit $?
fi

# Collect hits excluding binary wallpapers and known docs that only mention migration
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
hits_file="${tmpdir}/hits.txt"
: >"$hits_file"

for root in "${SEARCH_ROOTS[@]}"; do
  [[ -e "$root" ]] || continue
  # text-ish files only
  while IFS= read -r -d '' f; do
    case "$f" in
      *.jpg|*.jpeg|*.png|*.webp|*.gif|*.ico|*.svg|*.woff|*.woff2|*.ttf|*.otf)
        continue
        ;;
    esac
    if grep -nEi "$PATTERN" "$f" >/dev/null 2>&1; then
      grep -nEi "$PATTERN" "$f" | while IFS= read -r line; do
        printf '%s:%s\n' "$f" "$line"
      done >>"$hits_file"
    fi
  done < <(find "$root" -type f -print0 2>/dev/null)
done

# Allow explicit migration / negation notes (comments that document removal).
# Match whole-line intent: "no wofi", "are not used", "not swaybg", etc.
filtered="${tmpdir}/filtered.txt"
: >"$filtered"
if [[ -s "$hits_file" ]]; then
  while IFS= read -r hit; do
    content="${hit#*:}"
    content="${content#*:}"
    if echo "$content" | grep -qiE \
      'do not use|don.t use|are not used|is not used|not used|removed|obsolete|migrat|replaced by|no longer|forbidden|was wofi|was swaybg|not wofi|not swaybg|\bno[[:space:]]+wofi\b|\bno[[:space:]]+swaybg\b'; then
      continue
    fi
    echo "$hit" >>"$filtered"
  done <"$hits_file"
fi

if [[ -s "$filtered" ]]; then
  count="$(wc -l <"$filtered" | tr -d ' ')"
  qa_fail "${CHECK_ID}.refs" "found ${count} live wofi/swaybg reference(s)"
  head -50 "$filtered" >&2
  if [[ "$count" -gt 50 ]]; then
    echo "    … truncated …" >&2
  fi
else
  if [[ -s "$hits_file" ]]; then
    qa_pass "${CHECK_ID}.refs" "only migration-comment mentions (filtered OK)"
  else
    qa_pass "${CHECK_ID}.refs" "no wofi/swaybg references under skel/theme trees"
  fi
fi

# Positive signal: walker + hyprpaper expected in skel when present.
# Skel uses absolute symlinks into /usr/share (broken on host) — only scan real files.
if [[ -d build_files/etc/skel/.config ]]; then
  if find build_files/etc/skel -type f -print0 2>/dev/null \
    | xargs -0 grep -lE '(^|[^[:alnum:]_-])walker([^[:alnum:]_-]|$)' 2>/dev/null \
    | grep -q .; then
    qa_pass "${CHECK_ID}.walker" "skel references walker"
  else
    qa_warn "${CHECK_ID}.walker" "skel has no walker reference — check launcher stack"
  fi
  if find build_files/etc/skel -type f -print0 2>/dev/null \
    | xargs -0 grep -lE '(^|[^[:alnum:]_-])hyprpaper([^[:alnum:]_-]|$)' 2>/dev/null \
    | grep -q .; then
    qa_pass "${CHECK_ID}.hyprpaper" "skel references hyprpaper"
  else
    qa_warn "${CHECK_ID}.hyprpaper" "skel has no hyprpaper reference — check wallpaper stack"
  fi
fi

qa_print_summary "check-no-wofi-swaybg"
qa_exit_code
