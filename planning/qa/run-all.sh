#!/usr/bin/env bash
# Hyprwave packaging QA harness — run all checks, print summary, non-zero on FAIL.
#
# Usage (from repo root or any cwd):
#   bash planning/qa/run-all.sh
#   bash planning/qa/run-all.sh --only pins,themes
#   NO_COLOR=1 bash planning/qa/run-all.sh
#
# Exit codes:
#   0 — no FAIL (WARN/SKIP allowed)
#   1 — at least one check returned FAIL / non-zero
#   2 — harness misconfiguration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

# Ordered check list: id -> script
declare -a CHECK_ORDER=(
  pins-static
  themes
  no-wofi-swaybg
  duress-safety
  assistant
  image
  lane-artifacts
)

declare -A CHECK_SCRIPTS=(
  [pins-static]="check-pins-static.sh"
  [themes]="check-themes.sh"
  [no-wofi-swaybg]="check-no-wofi-swaybg.sh"
  [duress-safety]="check-duress-safety.sh"
  [assistant]="check-assistant.sh"
  [image]="check-image.sh"
  [lane-artifacts]="check-lane-artifacts.sh"
)

usage() {
  cat <<'EOF'
Usage: bash planning/qa/run-all.sh [options]

Options:
  --only id[,id...]   Run subset of checks (ids: pins-static, themes,
                      no-wofi-swaybg, duress-safety, assistant, image,
                      lane-artifacts)
  --list              List available checks and exit
  -h, --help          Show this help

Environment:
  NO_COLOR=1              Disable ANSI colors
  ROOT                    Override repo root (default: auto from script path)
  LANE_ARTIFACTS_OFF=1    Skip multi-ref lane checks (also used by CI static job)
  ORIGIN_LANE_A..G        Override git refs for lane-artifacts (default origin/lane/*)
  HYPRWAVE_IMAGE          Image for check-image (default localhost/hyprwave:latest)
  HYPRWAVE_COSMIC_IMAGE   Optional cosmic image (default localhost/hyprwave-cosmic:latest)

Exit codes:
  0  no FAIL (WARN/SKIP allowed — e.g. missing lane not yet merged)
  1  at least one check returned FAIL / non-zero
  2  harness misconfiguration (unknown --only id, bad flags)
EOF
}

ONLY=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      ONLY="${2:-}"
      shift 2
      ;;
    --list)
      printf 'Available checks:\n'
      for id in "${CHECK_ORDER[@]}"; do
        printf '  %-16s  %s\n' "$id" "${CHECK_SCRIPTS[$id]}"
      done
      exit 0
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

declare -a TO_RUN=()
if [[ -n "$ONLY" ]]; then
  IFS=',' read -r -a wanted <<<"$ONLY"
  for id in "${wanted[@]}"; do
    id="$(echo "$id" | tr -d '[:space:]')"
    if [[ -z "${CHECK_SCRIPTS[$id]:-}" ]]; then
      echo "Unknown check id: $id" >&2
      exit 2
    fi
    TO_RUN+=("$id")
  done
else
  TO_RUN=("${CHECK_ORDER[@]}")
fi

echo "Hyprwave QA harness"
echo "  repo:   $ROOT"
echo "  checks: ${TO_RUN[*]}"
echo "  time:   $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo

# Aggregate summary across child processes via temp status files
summary_dir="$(mktemp -d)"
trap 'rm -rf "$summary_dir"' EXIT

overall_fail=0
declare -a ROW_STATUS=()
declare -a ROW_ID=()
declare -a ROW_DETAIL=()

for id in "${TO_RUN[@]}"; do
  script="${SCRIPT_DIR}/${CHECK_SCRIPTS[$id]}"
  if [[ ! -f "$script" ]]; then
    ROW_STATUS+=("FAIL")
    ROW_ID+=("$id")
    ROW_DETAIL+=("script missing: $script")
    overall_fail=1
    continue
  fi
  if [[ ! -x "$script" ]]; then
    chmod +x "$script" 2>/dev/null || true
  fi

  echo "------------------------------------------------------------"
  echo ">> ${id}: ${CHECK_SCRIPTS[$id]}"
  echo "------------------------------------------------------------"
  set +e
  bash "$script"
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]]; then
    ROW_STATUS+=("PASS")
    ROW_ID+=("$id")
    ROW_DETAIL+=("exit 0 (WARNs may still appear above)")
  else
    ROW_STATUS+=("FAIL")
    ROW_ID+=("$id")
    ROW_DETAIL+=("exit $rc")
    overall_fail=1
  fi
  echo
done

echo "============================================================"
echo " HARNESS SUMMARY"
echo "============================================================"
printf '%-6s  %-18s  %s\n' "STATUS" "CHECK" "DETAIL"
printf '%-6s  %-18s  %s\n' "------" "-----" "------"
for i in "${!ROW_ID[@]}"; do
  printf '%-6s  %-18s  %s\n' "${ROW_STATUS[$i]}" "${ROW_ID[$i]}" "${ROW_DETAIL[$i]}"
done
echo
if [[ "$overall_fail" -eq 0 ]]; then
  echo "RESULT: OK (no FAIL)"
  exit 0
fi
echo "RESULT: FAIL (one or more checks failed)"
exit 1
