#!/usr/bin/env bash
# Shared helpers for Hyprwave packaging QA checks.
# shellcheck disable=SC2034

# Resolve repo root: planning/qa/lib -> ../../../
if [[ -z "${ROOT:-}" ]]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
fi
export ROOT

# Result counters (caller may reset)
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0
SKIP_COUNT=0

# Optional: collect structured results for run-all summary
# Each entry: "STATUS|check-id|message"
declare -a QA_RESULTS=()

_qa_color() {
  local code="$1"
  shift
  if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
    printf '\033[%sm%s\033[0m' "$code" "$*"
  else
    printf '%s' "$*"
  fi
}

qa_pass() {
  local id="$1"
  shift
  local msg="$*"
  PASS_COUNT=$((PASS_COUNT + 1))
  QA_RESULTS+=("PASS|${id}|${msg}")
  printf '%s %s: %s\n' "$(_qa_color 32 PASS)" "$id" "$msg"
}

qa_fail() {
  local id="$1"
  shift
  local msg="$*"
  FAIL_COUNT=$((FAIL_COUNT + 1))
  QA_RESULTS+=("FAIL|${id}|${msg}")
  printf '%s %s: %s\n' "$(_qa_color 31 FAIL)" "$id" "$msg" >&2
}

qa_warn() {
  local id="$1"
  shift
  local msg="$*"
  WARN_COUNT=$((WARN_COUNT + 1))
  QA_RESULTS+=("WARN|${id}|${msg}")
  printf '%s %s: %s\n' "$(_qa_color 33 WARN)" "$id" "$msg"
}

qa_skip() {
  local id="$1"
  shift
  local msg="$*"
  SKIP_COUNT=$((SKIP_COUNT + 1))
  QA_RESULTS+=("SKIP|${id}|${msg}")
  printf '%s %s: %s\n' "$(_qa_color 36 SKIP)" "$id" "$msg"
}

# Exit helper: non-zero if any FAIL
qa_exit_code() {
  if [[ "$FAIL_COUNT" -gt 0 ]]; then
    return 1
  fi
  return 0
}

# Print a markdown-ish summary table of QA_RESULTS
qa_print_summary() {
  local title="${1:-QA summary}"
  echo
  echo "=== ${title} ==="
  printf '%-6s  %-28s  %s\n' "STATUS" "CHECK" "MESSAGE"
  printf '%-6s  %-28s  %s\n' "------" "-----" "-------"
  local row status id msg
  for row in "${QA_RESULTS[@]:-}"; do
    [[ -z "$row" ]] && continue
    status="${row%%|*}"
    rest="${row#*|}"
    id="${rest%%|*}"
    msg="${rest#*|}"
    printf '%-6s  %-28s  %s\n' "$status" "$id" "$msg"
  done
  echo
  printf 'Totals: PASS=%s FAIL=%s WARN=%s SKIP=%s\n' \
    "$PASS_COUNT" "$FAIL_COUNT" "$WARN_COUNT" "$SKIP_COUNT"
}

# Soft-missing artifact: WARN (visible), not silent PASS
qa_missing_artifact() {
  local id="$1"
  local path="$2"
  local note="${3:-lane artifact not present on this tree}"
  qa_warn "$id" "missing ${path} — ${note}"
}
