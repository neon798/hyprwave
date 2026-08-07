#!/usr/bin/env bash
# verify-pins.sh — validate companion-app pins from build_files/versions.env
#
# Usage (any cwd; resolves repo root from this script's path):
#   bash planning/integration/a-stabilize/scripts/verify-pins.sh
#   bash planning/integration/a-stabilize/scripts/verify-pins.sh --help
#   bash planning/integration/a-stabilize/scripts/verify-pins.sh --head          # default: HTTP HEAD only
#   bash planning/integration/a-stabilize/scripts/verify-pins.sh --checksum     # download + sha256sum -c
#   bash planning/integration/a-stabilize/scripts/verify-pins.sh --checksum --light
#       # --light: skip Neonwolf AppImage (large); still checksum Yazi + FlatArcade assets
#
# Environment:
#   VERIFY_PINS_SKIP_NEONWOLF=1  — same as --light (for constrained CI/local)
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more URL/checksum failures or missing versions.env
#   2 — usage / bad args
#
# CI: .github/workflows/build.yml pin_guards runs default (--head) mode.
# Operators: run --checksum before publishing a pin bump or release.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts/ -> a-stabilize/ -> integration/ -> planning/ -> repo root
ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
VERSIONS="${ROOT}/build_files/versions.env"

MODE="head"
LIGHT=0

usage() {
	sed -n '2,22p' "$0" | sed 's/^# \?//'
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--help | -h)
		usage
		exit 0
		;;
	--head)
		MODE="head"
		shift
		;;
	--checksum | --sha256)
		MODE="checksum"
		shift
		;;
	--light)
		LIGHT=1
		shift
		;;
	*)
		echo "ERROR: unknown arg: $1 (try --help)" >&2
		exit 2
		;;
	esac
done

if [[ "${VERIFY_PINS_SKIP_NEONWOLF:-}" == "1" ]]; then
	LIGHT=1
fi

if [[ ! -f "${VERSIONS}" ]]; then
	echo "ERROR: missing ${VERSIONS}" >&2
	exit 1
fi

# shellcheck source=/dev/null
. "${VERSIONS}"

fail=0
TMPDIR_PINS=""

cleanup() {
	if [[ -n "${TMPDIR_PINS}" && -d "${TMPDIR_PINS}" ]]; then
		rm -rf "${TMPDIR_PINS}"
	fi
}
trap cleanup EXIT

check_url_head() {
	local name="$1"
	local url="$2"
	local code

	if [[ -z "${url}" ]]; then
		echo "FAIL  ${name}: empty URL"
		fail=1
		return
	fi

	# HEAD + follow redirects. Do not use -f so we can report the status code.
	code="$(
		curl -sS -o /dev/null -w '%{http_code}' -L -I --max-time 45 "${url}" 2>/dev/null ||
			echo "000"
	)"

	case "${code}" in
	2?? | 3??)
		echo "OK    ${name}: HTTP ${code}  ${url}"
		;;
	*)
		echo "FAIL  ${name}: HTTP ${code}  ${url}"
		fail=1
		;;
	esac
}

check_url_checksum() {
	local name="$1"
	local url="$2"
	local expected="$3"
	local dest

	if [[ -z "${url}" || -z "${expected}" ]]; then
		echo "FAIL  ${name}: empty URL or SHA256"
		fail=1
		return
	fi

	dest="${TMPDIR_PINS}/${name}.bin"
	echo "GET   ${name}: ${url}"
	if ! curl -fsSL --max-time 600 -o "${dest}" "${url}"; then
		echo "FAIL  ${name}: download failed"
		fail=1
		return
	fi

	if echo "${expected}  ${dest}" | sha256sum -c -; then
		echo "OK    ${name}: sha256 matches"
	else
		echo "FAIL  ${name}: sha256 mismatch (expected ${expected})"
		fail=1
	fi
}

echo "Repo root: ${ROOT}"
echo "Pins file: ${VERSIONS}"
mode_note=""
if [[ "${LIGHT}" -eq 1 ]]; then
	mode_note=" (light: skip Neonwolf)"
fi
echo "Mode: ${MODE}${mode_note}"
echo "Versions: Yazi=${YAZI_VERSION:-?} Neonwolf=${NEONWOLF_VERSION:-?} FlatArcade=${FLATARCADE_VERSION:-?}"
echo "---"

# --- Static guards (no network) ---
# Fail before HEAD/download if keys, digests, or floating URLs are wrong.
require_nonempty() {
	local name="$1"
	local value="${2:-}"
	if [[ -z "${value}" ]]; then
		echo "FAIL  ${name}: empty or unset in versions.env"
		fail=1
		return 1
	fi
	return 0
}

require_sha_format() {
	local name="$1"
	local value="${2:-}"
	if ! require_nonempty "${name}" "${value}"; then
		return
	fi
	if [[ ! "${value}" =~ ^[0-9a-fA-F]{64}$ ]]; then
		echo "FAIL  ${name}: not 64-char hex sha256 (${value})"
		fail=1
		return
	fi
	echo "OK    ${name}: sha256 format"
}

forbid_latest_url() {
	local name="$1"
	local url="${2:-}"
	local floating
	floating="$(printf '%s/%s' releases latest)"
	if ! require_nonempty "${name}" "${url}"; then
		return
	fi
	if [[ "${url}" == *"/${floating}"* ]]; then
		echo "FAIL  ${name}: uses floating GitHub release redirect (${url})"
		fail=1
		return
	fi
	echo "OK    ${name}: not floating latest"
}

require_nonempty "YAZI_VERSION" "${YAZI_VERSION:-}" || true
require_nonempty "NEONWOLF_VERSION" "${NEONWOLF_VERSION:-}" || true
require_nonempty "FLATARCADE_VERSION" "${FLATARCADE_VERSION:-}" || true
forbid_latest_url "YAZI_URL" "${YAZI_URL:-}"
forbid_latest_url "NEONWOLF_URL" "${NEONWOLF_URL:-}"
forbid_latest_url "FLATARCADE_URL" "${FLATARCADE_URL:-}"
forbid_latest_url "FLATARCADE_SVG_URL" "${FLATARCADE_SVG_URL:-}"
require_sha_format "YAZI_SHA256" "${YAZI_SHA256:-}"
require_sha_format "NEONWOLF_SHA256" "${NEONWOLF_SHA256:-}"
require_sha_format "FLATARCADE_SHA256" "${FLATARCADE_SHA256:-}"
require_sha_format "FLATARCADE_SVG_SHA256" "${FLATARCADE_SVG_SHA256:-}"

# Also fail if build.sh itself regressed to floating tags (local/CI parity).
# Grep the literal token so accidental URL reintroduction is caught; helpers
# construct the path at runtime so this check stays green on intentional guards.
BUILD_SH="${ROOT}/build_files/build.sh"
VERSIONS_ENV="${ROOT}/build_files/versions.env"
FLOATING_TOKEN="$(printf '%s/%s' releases latest)"
if [[ -f "${BUILD_SH}" ]]; then
	if grep -nF "${FLOATING_TOKEN}" "${BUILD_SH}"; then
		echo "FAIL  build_files/build.sh contains floating-release token"
		fail=1
	else
		echo "OK    build_files/build.sh: no floating-release token"
	fi
	if ! grep -q 'versions\.env' "${BUILD_SH}"; then
		echo "FAIL  build_files/build.sh does not reference versions.env"
		fail=1
	else
		echo "OK    build_files/build.sh sources versions.env"
	fi
	if ! grep -q 'verify_sha256' "${BUILD_SH}"; then
		echo "FAIL  build_files/build.sh missing verify_sha256 usage"
		fail=1
	else
		echo "OK    build_files/build.sh uses verify_sha256"
	fi
else
	echo "FAIL  missing ${BUILD_SH}"
	fail=1
fi
if [[ -f "${VERSIONS_ENV}" ]]; then
	if grep -nF "${FLOATING_TOKEN}" "${VERSIONS_ENV}"; then
		echo "FAIL  versions.env contains floating-release token"
		fail=1
	else
		echo "OK    versions.env: no floating-release token"
	fi
fi

if [[ "${fail}" -ne 0 ]]; then
	echo "---"
	echo "verify-pins: FAILED (static checks; skipped network)"
	exit 1
fi

echo "---"

if [[ "${MODE}" == "head" ]]; then
	check_url_head "YAZI_URL" "${YAZI_URL:-}"
	check_url_head "NEONWOLF_URL" "${NEONWOLF_URL:-}"
	check_url_head "FLATARCADE_URL" "${FLATARCADE_URL:-}"
	check_url_head "FLATARCADE_SVG_URL" "${FLATARCADE_SVG_URL:-}"
else
	TMPDIR_PINS="$(mktemp -d "${TMPDIR:-/tmp}/hyprwave-verify-pins.XXXXXX")"
	check_url_checksum "YAZI" "${YAZI_URL:-}" "${YAZI_SHA256:-}"
	if [[ "${LIGHT}" -eq 1 ]]; then
		echo "SKIP  NEONWOLF: light mode (run without --light for full AppImage checksum)"
		check_url_head "NEONWOLF_URL" "${NEONWOLF_URL:-}"
	else
		check_url_checksum "NEONWOLF" "${NEONWOLF_URL:-}" "${NEONWOLF_SHA256:-}"
	fi
	check_url_checksum "FLATARCADE" "${FLATARCADE_URL:-}" "${FLATARCADE_SHA256:-}"
	check_url_checksum "FLATARCADE_SVG" "${FLATARCADE_SVG_URL:-}" "${FLATARCADE_SVG_SHA256:-}"
fi

echo "---"
if [[ "${fail}" -ne 0 ]]; then
	echo "verify-pins: FAILED"
	exit 1
fi
echo "verify-pins: all checks passed (mode=${MODE})"
