#!/usr/bin/env bash
# Optional multi-lane artifact presence checks against remote (or override) refs.
#
# Soft-WARN when a lane ref is missing (not fetched / not published yet).
# FAIL only when the ref exists but an expected path is absent.
#
# Usage:
#   bash planning/qa/check-lane-artifacts.sh
#   ORIGIN_LANE_A=origin/lane/a-stabilize bash planning/qa/check-lane-artifacts.sh
#   LANE_ARTIFACTS_OFF=1 bash planning/qa/check-lane-artifacts.sh   # skip entirely
#
# Requires: git. If git is unavailable, soft-WARN and exit 0.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

CHECK_ID="lane-artifacts"
echo "== check-lane-artifacts (repo: $ROOT) =="

if [[ "${LANE_ARTIFACTS_OFF:-0}" == "1" ]]; then
  qa_skip "${CHECK_ID}.disabled" "LANE_ARTIFACTS_OFF=1 — skipping multi-ref checks"
  qa_print_summary "check-lane-artifacts"
  qa_exit_code
  exit $?
fi

if ! command -v git >/dev/null 2>&1; then
  qa_warn "${CHECK_ID}.git" "git not on PATH — cannot inspect lane refs (soft-skip)"
  qa_print_summary "check-lane-artifacts"
  qa_exit_code
  exit $?
fi

if ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  qa_warn "${CHECK_ID}.repo" "not a git work tree — soft-skip"
  qa_print_summary "check-lane-artifacts"
  qa_exit_code
  exit $?
fi

# Default remote refs; overridable via ORIGIN_LANE_<LETTER>
ref_for() {
  local letter="$1"
  local env_key="ORIGIN_LANE_${letter}"
  local default="origin/lane/"
  case "$letter" in
    A) default="origin/lane/a-stabilize" ;;
    B) default="origin/lane/b-docs" ;;
    C) default="origin/lane/c-assistant" ;;
    D) default="origin/lane/d-duress" ;;
    E) default="origin/lane/e-hyprland" ;;
    F) default="origin/lane/f-cosmic" ;;
    G) default="origin/lane/g-qa" ;;
    *) default="origin/lane/unknown" ;;
  esac
  # Indirect expand of ORIGIN_LANE_X if set
  local override="${!env_key:-}"
  if [[ -n "$override" ]]; then
    printf '%s' "$override"
  else
    printf '%s' "$default"
  fi
}

# ref_exists: resolve as commit-ish (branch tip, remote-tracking, or SHA)
ref_exists() {
  local ref="$1"
  git -C "$ROOT" rev-parse --verify --quiet "${ref}^{commit}" >/dev/null 2>&1
}

# path_on_ref: true if path exists as blob or tree on ref
path_on_ref() {
  local ref="$1"
  local path="$2"
  git -C "$ROOT" cat-file -e "${ref}:${path}" 2>/dev/null
}

# Expected artifacts per lane (paths relative to repo root).
# Keep this list intentionally small and high-signal for ENDPOINT closeout.
declare -a LANE_LETTERS=(A B C D E F G)

paths_for() {
  local letter="$1"
  case "$letter" in
    A)
      printf '%s\n' \
        "build_files/versions.env" \
        "planning/integration/a-stabilize/scripts/verify-pins.sh" \
        "planning/integration/a-stabilize/RELEASE.md"
      ;;
    B)
      printf '%s\n' \
        "INSTALL.md" \
        "CHANGELOG.md" \
        "docs/troubleshooting.md" \
        "docs/architecture.md" \
        "docs/keybinds.md"
      ;;
    C)
      printf '%s\n' \
        "apps/hyprwave-assistant/go.mod" \
        "apps/hyprwave-assistant/main.go" \
        "planning/integration/c-assistant/build.sh.snippet" \
        "planning/integration/c-assistant/Containerfile.snippet"
      ;;
    D)
      printf '%s\n' \
        "build_files/duress/ENABLE.md" \
        "planning/integration/d-duress/validate.sh" \
        "planning/integration/d-duress/build.sh.snippet" \
        "planning/integration/d-duress/Containerfile.snippet"
      ;;
    E)
      printf '%s\n' \
        "planning/integration/e-hyprland/SESSION-SMOKE.md" \
        "planning/integration/e-hyprland/KEYBIND-MAP.md" \
        "build_files/etc/skel/.config/hypr/autostart.conf" \
        "build_files/etc/skel/.config/walker/config.toml"
      ;;
    F)
      printf '%s\n' \
        "planning/integration/f-cosmic/SESSION-SMOKE.md" \
        "planning/integration/f-cosmic/VENDOR-INVENTORY.md" \
        "build_files/usr/share/cosmic/com.system76.CosmicAppList/v1/favorites"
      ;;
    G)
      printf '%s\n' \
        "planning/qa/run-all.sh" \
        "planning/integration/g-qa/MERGE-PLAYBOOK.md"
      ;;
  esac
}

refs_checked=0
refs_missing=0
paths_ok=0
paths_fail=0

for letter in "${LANE_LETTERS[@]}"; do
  ref="$(ref_for "$letter")"
  id_prefix="${CHECK_ID}.${letter}"

  if ! ref_exists "$ref"; then
    qa_warn "${id_prefix}.ref" "ref missing: ${ref} (soft — fetch origin or set ORIGIN_LANE_${letter})"
    refs_missing=$((refs_missing + 1))
    continue
  fi

  refs_checked=$((refs_checked + 1))
  short="$(git -C "$ROOT" rev-parse --short "${ref}^{commit}" 2>/dev/null || echo '?')"
  qa_pass "${id_prefix}.ref" "ref present: ${ref} @ ${short}"

  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    if path_on_ref "$ref" "$path"; then
      qa_pass "${id_prefix}.path" "${ref}:${path}"
      paths_ok=$((paths_ok + 1))
    else
      qa_fail "${id_prefix}.path" "ref present but missing path: ${ref}:${path}"
      paths_fail=$((paths_fail + 1))
    fi
  done < <(paths_for "$letter")
done

qa_pass "${CHECK_ID}.summary" \
  "refs_checked=${refs_checked} refs_missing=${refs_missing} paths_ok=${paths_ok} paths_fail=${paths_fail}"

qa_print_summary "check-lane-artifacts"
qa_exit_code
