#!/usr/bin/env bash
# Verify that pinned companion-app URLs from build_files/versions.env are reachable.
# Intended for local use and CI pin_guards (HEAD requests only — no full download).
#
# Usage (from repo root or any cwd):
#   bash planning/integration/a-stabilize/scripts/verify-pins.sh
#
# Exit 0 if every URL returns HTTP 2xx/3xx after redirects; non-zero otherwise.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# scripts/ -> a-stabilize/ -> integration/ -> planning/ -> repo root
ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
VERSIONS="${ROOT}/build_files/versions.env"

if [[ ! -f "${VERSIONS}" ]]; then
	echo "ERROR: missing ${VERSIONS}" >&2
	exit 1
fi

# shellcheck source=/dev/null
. "${VERSIONS}"

fail=0

check_url() {
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

echo "Repo root: ${ROOT}"
echo "Pins file: ${VERSIONS}"
echo "Versions: Yazi=${YAZI_VERSION:-?} Neonwolf=${NEONWOLF_VERSION:-?} FlatArcade=${FLATARCADE_VERSION:-?}"
echo "---"

check_url "YAZI_URL" "${YAZI_URL:-}"
check_url "NEONWOLF_URL" "${NEONWOLF_URL:-}"
check_url "FLATARCADE_URL" "${FLATARCADE_URL:-}"
check_url "FLATARCADE_SVG_URL" "${FLATARCADE_SVG_URL:-}"

echo "---"
if [[ "${fail}" -ne 0 ]]; then
	echo "verify-pins: one or more URLs failed"
	exit 1
fi
echo "verify-pins: all pinned URLs reachable"
