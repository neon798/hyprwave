#!/usr/bin/env bash
# Read-only merge conflict probe: git merge-tree each origin/lane/* against a base.
#
# Does **not** touch the index or working tree. Safe to run anytime.
#
# Usage (from repo root):
#   bash planning/qa/probe-merge-conflicts.sh
#   bash planning/qa/probe-merge-conflicts.sh --base origin/main
#   bash planning/qa/probe-merge-conflicts.sh --fail-on-conflict
#   bash planning/qa/probe-merge-conflicts.sh --product-only   # hide taskmaster/ noise
#   bash planning/qa/probe-merge-conflicts.sh --lanes a-stabilize,b-docs
#
# Exit codes (default report mode):
#   0 — probe completed (conflicts may have been reported)
#   2 — misconfiguration (git missing, bad flags, unknown lane)
# With --fail-on-conflict:
#   1 — at least one conflict path reported
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

BASE="${PROBE_BASE:-origin/main}"
FAIL_ON_CONFLICT=0
PRODUCT_ONLY=0
LANES_CSV=""

usage() {
  cat <<'EOF'
Usage: bash planning/qa/probe-merge-conflicts.sh [options]

Options:
  --base REF            Base commit/ref (default: origin/main or PROBE_BASE)
  --lanes a,b,...       Subset of lane short names (default: all seven)
  --fail-on-conflict    Exit 1 if any CONFLICT reported
  --product-only        Omit planning/taskmaster/** conflict lines from detail
  -h, --help            Show help

Environment:
  PROBE_BASE            Same as --base
  ORIGIN_LANE_A..G      Override refs (same contract as check-lane-artifacts.sh)
  NO_COLOR=1            Disable colors via common.sh helpers
EOF
}

# Map short name -> default remote ref
default_ref() {
  case "$1" in
    a-stabilize|a) printf '%s' "${ORIGIN_LANE_A:-origin/lane/a-stabilize}" ;;
    b-docs|b)      printf '%s' "${ORIGIN_LANE_B:-origin/lane/b-docs}" ;;
    c-assistant|c) printf '%s' "${ORIGIN_LANE_C:-origin/lane/c-assistant}" ;;
    d-duress|d)    printf '%s' "${ORIGIN_LANE_D:-origin/lane/d-duress}" ;;
    e-hyprland|e)  printf '%s' "${ORIGIN_LANE_E:-origin/lane/e-hyprland}" ;;
    f-cosmic|f)    printf '%s' "${ORIGIN_LANE_F:-origin/lane/f-cosmic}" ;;
    g-qa|g)        printf '%s' "${ORIGIN_LANE_G:-origin/lane/g-qa}" ;;
    *) return 1 ;;
  esac
}

ALL_LANES=(a-stabilize b-docs c-assistant d-duress e-hyprland f-cosmic g-qa)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)
      BASE="${2:-}"
      shift 2
      ;;
    --lanes)
      LANES_CSV="${2:-}"
      shift 2
      ;;
    --fail-on-conflict)
      FAIL_ON_CONFLICT=1
      shift
      ;;
    --product-only)
      PRODUCT_ONLY=1
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

if ! command -v git >/dev/null 2>&1; then
  echo "git not found" >&2
  exit 2
fi

if ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not a git work tree: $ROOT" >&2
  exit 2
fi

if ! git -C "$ROOT" rev-parse --verify --quiet "${BASE}^{commit}" >/dev/null; then
  echo "base ref not found: $BASE (fetch remotes?)" >&2
  exit 2
fi

# Prefer modern merge-tree (Git ≥2.38): --write-tree merges a ref with itself.
if ! git merge-tree --write-tree "$BASE" "$BASE" >/dev/null 2>&1; then
  echo "git merge-tree --write-tree unavailable; need Git ≥2.38" >&2
  exit 2
fi

declare -a LANES=()
if [[ -n "$LANES_CSV" ]]; then
  IFS=',' read -r -a raw <<<"$LANES_CSV"
  for name in "${raw[@]}"; do
    name="$(echo "$name" | tr -d '[:space:]')"
    [[ -z "$name" ]] && continue
    if ! default_ref "$name" >/dev/null; then
      echo "unknown lane: $name" >&2
      exit 2
    fi
    # normalize short aliases to long names
    case "$name" in
      a) name=a-stabilize ;;
      b) name=b-docs ;;
      c) name=c-assistant ;;
      d) name=d-duress ;;
      e) name=e-hyprland ;;
      f) name=f-cosmic ;;
      g) name=g-qa ;;
    esac
    LANES+=("$name")
  done
else
  LANES=("${ALL_LANES[@]}")
fi

echo "Merge conflict probe (read-only merge-tree)"
echo "  repo:  $ROOT"
echo "  base:  $BASE @ $(git -C "$ROOT" rev-parse --short "${BASE}^{commit}")"
echo "  lanes: ${LANES[*]}"
echo "  mode:  $([[ "$FAIL_ON_CONFLICT" -eq 1 ]] && echo fail-on-conflict || echo report)"
echo "  time:  $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo

total_conflicts=0
declare -a ROW_LANE=()
declare -a ROW_REF=()
declare -a ROW_STATUS=()
declare -a ROW_DETAIL=()

for lane in "${LANES[@]}"; do
  ref="$(default_ref "$lane")"
  if ! git -C "$ROOT" rev-parse --verify --quiet "${ref}^{commit}" >/dev/null; then
    qa_warn "probe.${lane}" "ref missing: ${ref}"
    ROW_LANE+=("$lane")
    ROW_REF+=("$ref")
    ROW_STATUS+=("WARN")
    ROW_DETAIL+=("ref missing")
    continue
  fi

  short="$(git -C "$ROOT" rev-parse --short "${ref}^{commit}")"
  mb="$(git -C "$ROOT" merge-base "$BASE" "$ref")"
  mb_short="$(git -C "$ROOT" rev-parse --short "$mb")"

  set +e
  # --messages prints CONFLICT lines; non-zero exit when conflicts exist
  out="$(git -C "$ROOT" merge-tree --write-tree --messages "$BASE" "$ref" 2>&1)"
  rc=$?
  set -e

  mapfile -t conflict_lines < <(printf '%s\n' "$out" | grep -E 'CONFLICT \(' || true)
  if [[ "$PRODUCT_ONLY" -eq 1 ]]; then
    mapfile -t conflict_lines < <(printf '%s\n' "${conflict_lines[@]:-}" \
      | grep -v 'planning/taskmaster/' || true)
  fi

  n=${#conflict_lines[@]}
  # empty array can still be size 1 with empty string depending on mapfile
  if [[ "$n" -eq 1 && -z "${conflict_lines[0]:-}" ]]; then
    n=0
  fi

  product_file_count="$(git -C "$ROOT" diff --name-only "$mb" "$ref" \
    | grep -vcE '^planning/taskmaster/' || true)"

  echo "------------------------------------------------------------"
  echo ">> ${lane}  ${ref} @ ${short}  (merge-base ${mb_short})"
  echo "   product paths changed vs base: ${product_file_count}"
  echo "   merge-tree exit: ${rc}"

  if [[ "$n" -eq 0 ]]; then
    # If raw merge-tree had only taskmaster conflicts and --product-only, treat as clean product
    if [[ "$rc" -ne 0 && "$PRODUCT_ONLY" -eq 1 ]]; then
      qa_pass "probe.${lane}" "no product conflicts (taskmaster-only noise filtered)"
      ROW_STATUS+=("PASS")
      ROW_DETAIL+=("product-clean (taskmaster conflicts filtered); files=${product_file_count}")
    elif [[ "$rc" -eq 0 ]]; then
      qa_pass "probe.${lane}" "clean merge-tree vs ${BASE}"
      ROW_STATUS+=("PASS")
      ROW_DETAIL+=("clean; product_files=${product_file_count}")
    else
      # Conflicts existed but grep missed (unexpected) — surface
      qa_warn "probe.${lane}" "merge-tree non-zero but no CONFLICT lines parsed"
      ROW_STATUS+=("WARN")
      ROW_DETAIL+=("merge-tree rc=${rc}; files=${product_file_count}")
    fi
  else
    total_conflicts=$((total_conflicts + n))
    qa_fail "probe.${lane}" "${n} conflict path(s) vs ${BASE}"
    for line in "${conflict_lines[@]}"; do
      echo "    $line"
    done
    ROW_STATUS+=("CONFLICT")
    ROW_DETAIL+=("${n} conflicts; product_files=${product_file_count}")
  fi

  ROW_LANE+=("$lane")
  ROW_REF+=("${ref}@${short}")
  echo
done

echo "============================================================"
echo " PROBE SUMMARY"
echo "============================================================"
printf '%-8s  %-36s  %s\n' "STATUS" "LANE / REF" "DETAIL"
printf '%-8s  %-36s  %s\n' "------" "---------" "------"
for i in "${!ROW_LANE[@]}"; do
  printf '%-8s  %-36s  %s\n' "${ROW_STATUS[$i]}" "${ROW_LANE[$i]} ${ROW_REF[$i]}" "${ROW_DETAIL[$i]}"
done
echo
echo "Total CONFLICT lines (this run): ${total_conflicts}"
echo "Note: pairwise vs ${BASE} only — serial merges may differ after A lands."
echo "Full narrative: planning/integration/g-qa/PRE-MERGE-DRY-RUN.md"
echo

if [[ "$FAIL_ON_CONFLICT" -eq 1 && "$total_conflicts" -gt 0 ]]; then
  echo "RESULT: FAIL (--fail-on-conflict and conflicts found)"
  exit 1
fi
echo "RESULT: OK (report complete)"
exit 0
