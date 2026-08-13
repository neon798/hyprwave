#!/usr/bin/env bash
# Static pin checks: no /releases/latest, versions.env keys when present.
# Safe on main before Model A merges — soft-WARN when pin files absent.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
cd "$ROOT"

CHECK_ID="pins-static"
echo "== check-pins-static (repo: $ROOT) =="

BUILD_SH="build_files/build.sh"
VERSIONS_ENV="build_files/versions.env"

# Required keys when versions.env exists (Model A contract)
REQUIRED_KEYS=(
  YAZI_VERSION
  YAZI_URL
  YAZI_SHA256
  NEONWOLF_VERSION
  NEONWOLF_URL
  NEONWOLF_SHA256
  FLATARCADE_VERSION
  FLATARCADE_URL
  FLATARCADE_SHA256
)

# --- releases/latest in packaging scripts ---
if [[ -f "$BUILD_SH" ]]; then
  # Ignore pure comments that only document the anti-pattern? Still count URL uses.
  # Match path segment /releases/latest (GitHub floating tag pattern).
  mapfile -t latest_hits < <(grep -nE '/releases/latest' "$BUILD_SH" || true)
  if [[ ${#latest_hits[@]} -eq 0 ]]; then
    qa_pass "${CHECK_ID}.no-latest" "${BUILD_SH}: no /releases/latest"
  else
    qa_fail "${CHECK_ID}.no-latest" \
      "${BUILD_SH}: found ${#latest_hits[@]} /releases/latest reference(s) (pin required)"
    for line in "${latest_hits[@]}"; do
      echo "    $line" >&2
    done
  fi
else
  qa_missing_artifact "${CHECK_ID}.build-sh" "$BUILD_SH" "unexpected on this repo"
fi

# Also scan common pin snippet / helper locations if present
for extra in \
  "planning/integration/a-stabilize/scripts/verify-pins.sh" \
  "build_files/pin-versions.env"; do
  if [[ -f "$extra" ]]; then
    if grep -nE '/releases/latest' "$extra" >/dev/null 2>&1; then
      qa_fail "${CHECK_ID}.extra-latest" "$extra still references /releases/latest"
      grep -nE '/releases/latest' "$extra" >&2 || true
    else
      qa_pass "${CHECK_ID}.extra-latest" "$extra: no /releases/latest"
    fi
  fi
done

# --- versions.env presence + keys ---
if [[ ! -f "$VERSIONS_ENV" ]]; then
  qa_missing_artifact "${CHECK_ID}.versions-env" "$VERSIONS_ENV" \
    "Model A not merged yet; re-run after lane/a-stabilize"
else
  qa_pass "${CHECK_ID}.versions-env" "${VERSIONS_ENV} present"

  # shellcheck disable=SC1090
  set -a
  # shellcheck source=/dev/null
  source "$VERSIONS_ENV"
  set +a

  missing=()
  for key in "${REQUIRED_KEYS[@]}"; do
    if [[ -z "${!key:-}" ]]; then
      missing+=("$key")
    fi
  done
  if [[ ${#missing[@]} -eq 0 ]]; then
    qa_pass "${CHECK_ID}.keys" "all required pin keys present (${#REQUIRED_KEYS[@]})"
  else
    qa_fail "${CHECK_ID}.keys" "missing keys: ${missing[*]}"
  fi

  # URLs must not be latest even if build.sh is clean
  for url_var in YAZI_URL NEONWOLF_URL FLATARCADE_URL; do
    val="${!url_var:-}"
    if [[ -n "$val" && "$val" == *"/releases/latest"* ]]; then
      qa_fail "${CHECK_ID}.url-latest" "${url_var} points at /releases/latest"
    elif [[ -n "$val" ]]; then
      qa_pass "${CHECK_ID}.url-${url_var}" "${url_var} is versioned"
    fi
  done

  # SHA256 shape (64 hex)
  for sha_var in YAZI_SHA256 NEONWOLF_SHA256 FLATARCADE_SHA256; do
    val="${!sha_var:-}"
    if [[ -z "$val" ]]; then
      continue
    fi
    if [[ "$val" =~ ^[0-9a-fA-F]{64}$ ]]; then
      qa_pass "${CHECK_ID}.sha-${sha_var}" "${sha_var} looks like sha256"
    else
      qa_fail "${CHECK_ID}.sha-${sha_var}" "${sha_var} not 64-hex: ${val:0:16}…"
    fi
  done
fi

# Optional: A's verify-pins script syntax when present
VERIFY="planning/integration/a-stabilize/scripts/verify-pins.sh"
if [[ -f "$VERIFY" ]]; then
  if bash -n "$VERIFY"; then
    qa_pass "${CHECK_ID}.verify-syntax" "bash -n $VERIFY"
  else
    qa_fail "${CHECK_ID}.verify-syntax" "bash -n $VERIFY failed"
  fi
else
  qa_warn "${CHECK_ID}.verify-script" \
    "missing $VERIFY — soft-skip until a-stabilize present"
fi

qa_print_summary "check-pins-static"
qa_exit_code
