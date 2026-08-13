#!/usr/bin/env bash
# Duress packaging safety: no pre-signed *.sha256; run lane validate.sh when present.
# Soft-WARN if duress tree not on this checkout (lane not merged).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

CHECK_ID="duress-safety"
echo "== check-duress-safety (repo: $ROOT) =="

DURESS_TREE="build_files/duress"
BUILD_DURESS="build_files/build-duress.sh"
VALIDATE_CANDIDATES=(
  "planning/integration/d-duress/validate.sh"
  "build_files/duress/validate.sh"
)

has_duress=0
if [[ -d "$DURESS_TREE" ]]; then
  has_duress=1
fi
if [[ -f "$BUILD_DURESS" ]]; then
  has_duress=1
fi

if [[ "$has_duress" -eq 0 ]]; then
  qa_warn "${CHECK_ID}.tree" \
    "no ${DURESS_TREE} / ${BUILD_DURESS} — soft-skip until lane/d-duress merged"
  # Still note validate absence explicitly
  found_validate=0
  for v in "${VALIDATE_CANDIDATES[@]}"; do
    if [[ -f "$v" ]]; then
      found_validate=1
      qa_warn "${CHECK_ID}.orphan-validate" \
        "found $v without duress tree — unexpected layout"
    fi
  done
  if [[ "$found_validate" -eq 0 ]]; then
    qa_warn "${CHECK_ID}.validate" "validate.sh not present (expected after D merge)"
  fi
  qa_print_summary "check-duress-safety"
  # WARN-only when artifact missing is not a hard FAIL
  qa_exit_code
  exit $?
fi

qa_pass "${CHECK_ID}.tree" "duress packaging tree detected"

# --- no pre-signed scripts ---
mapfile -t sha_files < <(find "$DURESS_TREE" -type f -name '*.sha256' 2>/dev/null || true)
# Also scan related integration drops
mapfile -t sha_int < <(find planning/integration/d-duress -type f -name '*.sha256' 2>/dev/null || true)
all_sha=("${sha_files[@]:-}" "${sha_int[@]:-}")
# compact empty
real_sha=()
for f in "${all_sha[@]:-}"; do
  [[ -n "${f:-}" ]] && real_sha+=("$f")
done

if [[ ${#real_sha[@]} -gt 0 ]]; then
  qa_fail "${CHECK_ID}.sha256" "found ${#real_sha[@]} *.sha256 file(s) — must not ship signatures"
  printf '    %s\n' "${real_sha[@]}" >&2
else
  qa_pass "${CHECK_ID}.sha256" "no *.sha256 under duress packaging paths"
fi

# --- must not enable PAM by default in live /etc paths in snippets ---
for snip in \
  planning/integration/d-duress/build.sh.snippet \
  "$BUILD_DURESS"; do
  [[ -f "$snip" ]] || continue
  if grep -vE '^\s*#' "$snip" | grep -nE 'pam_duress\.so' >/dev/null 2>&1; then
    # Active install of pam_duress into live stacks is forbidden; allow docs-only strings
    if grep -vE '^\s*#' "$snip" | grep -nE '(auth\s+.*pam_duress|/etc/pam\.d/)' >/dev/null 2>&1; then
      qa_fail "${CHECK_ID}.pam-default" \
        "$snip has active pam_duress /etc/pam.d wiring (must stay OFF by default)"
      grep -nE 'pam_duress|/etc/pam\.d' "$snip" | grep -vE '^\s*#' | head -20 >&2 || true
    else
      qa_pass "${CHECK_ID}.pam-default" "$snip: no active PAM enablement"
    fi
  else
    qa_pass "${CHECK_ID}.pam-mention" "$snip: no active pam_duress lines (or file is docs-only)"
  fi
done

# --- run validate.sh if present ---
ran_validate=0
for v in "${VALIDATE_CANDIDATES[@]}"; do
  if [[ -f "$v" ]]; then
    ran_validate=1
    if bash -n "$v"; then
      qa_pass "${CHECK_ID}.validate-syntax" "bash -n $v"
    else
      qa_fail "${CHECK_ID}.validate-syntax" "bash -n $v failed"
      continue
    fi
    echo "-- running $v --"
    set +e
    bash "$v"
    rc=$?
    set -e
    if [[ "$rc" -eq 0 ]]; then
      qa_pass "${CHECK_ID}.validate-run" "$v exited 0"
    else
      qa_fail "${CHECK_ID}.validate-run" "$v exited $rc"
    fi
    # Prefer first found
    break
  fi
done

if [[ "$ran_validate" -eq 0 ]]; then
  qa_warn "${CHECK_ID}.validate" \
    "duress tree present but no validate.sh — recommend planning/integration/d-duress/validate.sh"
fi

# Templates should be present and shell-parseable when tree exists
if [[ -d "${DURESS_TREE}/templates" ]]; then
  shopt -s nullglob
  templates=("${DURESS_TREE}/templates"/*.sh)
  shopt -u nullglob
  if [[ ${#templates[@]} -eq 0 ]]; then
    qa_fail "${CHECK_ID}.templates" "no templates under ${DURESS_TREE}/templates"
  else
    for t in "${templates[@]}"; do
      if bash -n "$t"; then
        qa_pass "${CHECK_ID}.template-$(basename "$t")" "bash -n OK"
      else
        qa_fail "${CHECK_ID}.template-$(basename "$t")" "bash -n failed"
      fi
    done
  fi
fi

qa_print_summary "check-duress-safety"
qa_exit_code
