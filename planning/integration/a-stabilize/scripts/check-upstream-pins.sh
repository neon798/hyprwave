#!/usr/bin/env bash
# check-upstream-pins.sh — ADVISORY only: compare versions.env tags to GitHub latest
#
# Usage:
#   bash planning/integration/a-stabilize/scripts/check-upstream-pins.sh
#   bash planning/integration/a-stabilize/scripts/check-upstream-pins.sh --json
#
# Exit codes:
#   0 — script ran successfully (even if upstream is newer)
#   1 — could not read versions.env / network hard-fail for all probes
#   2 — bad args
#
# NEVER wire this into pin_guards / CI fail gates. Pins are deliberate;
# newer upstream is informational for operators (see BUMP.md / MERGE-READY.md).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
VERSIONS="${ROOT}/build_files/versions.env"
JSON=0

usage() {
	sed -n '2,18p' "$0" | sed 's/^# \?//'
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--help | -h)
		usage
		exit 0
		;;
	--json)
		JSON=1
		shift
		;;
	*)
		echo "ERROR: unknown arg: $1" >&2
		exit 2
		;;
	esac
done

if [[ ! -f "${VERSIONS}" ]]; then
	echo "ERROR: missing ${VERSIONS}" >&2
	exit 1
fi

# shellcheck source=/dev/null
. "${VERSIONS}"

# repo|pinned_version_var
COMPONENTS=(
	"sxyazi/yazi|YAZI_VERSION"
	"neon798/neonwolf|NEONWOLF_VERSION"
	"neon798/flatarcade|FLATARCADE_VERSION"
)

latest_tag() {
	local repo="$1"
	# Prefer API; fall back to redirect Location from releases/latest HTML.
	local tag=""
	tag="$(
		curl -fsSL --max-time 30 \
			-H "Accept: application/vnd.github+json" \
			-H "User-Agent: hyprwave-check-upstream-pins" \
			"https://api.github.com/repos/${repo}/releases/latest" 2>/dev/null |
			sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -1
	)" || true
	if [[ -z "${tag}" ]]; then
		tag="$(
			curl -fsSLI --max-time 30 \
				-H "User-Agent: hyprwave-check-upstream-pins" \
				"https://github.com/${repo}/releases/latest" 2>/dev/null |
				tr -d '\r' |
				sed -n 's|^[Ll]ocation: .*/tag/\([^/]*\)$|\1|p' | head -1
		)" || true
	fi
	printf '%s' "${tag}"
}

echo "Repo root: ${ROOT}"
echo "Pins file: ${VERSIONS}"
echo "Mode: ADVISORY (exit 0 even when upstream is newer)"
echo "---"

any_net=0
newer=0
json_items=""

for entry in "${COMPONENTS[@]}"; do
	repo="${entry%%|*}"
	var="${entry##*|}"
	pinned="${!var:-}"
	up="$(latest_tag "${repo}")"
	if [[ -n "${up}" ]]; then
		any_net=1
	fi

	status="unknown"
	if [[ -z "${pinned}" ]]; then
		status="missing_pin"
	elif [[ -z "${up}" ]]; then
		status="upstream_unreachable"
	elif [[ "${pinned}" == "${up}" ]]; then
		status="current"
	else
		status="upstream_newer"
		newer=1
	fi

	if [[ "${JSON}" -eq 1 ]]; then
		json_items+=$(printf '{"repo":"%s","pin_var":"%s","pinned":"%s","upstream_latest":"%s","status":"%s"},' \
			"${repo}" "${var}" "${pinned}" "${up}" "${status}")
	else
		printf '%-22s pin=%-16s latest=%-16s %s\n' "${repo}" "${pinned:-?}" "${up:-?}" "${status}"
	fi
done

echo "---"
if [[ "${JSON}" -eq 1 ]]; then
	json_items="${json_items%,}"
	printf '{"advisory":true,"components":[%s],"any_upstream_newer":%s}\n' \
		"${json_items}" "$([[ "${newer}" -eq 1 ]] && echo true || echo false)"
fi

if [[ "${any_net}" -eq 0 ]]; then
	echo "check-upstream-pins: no upstream tags resolved (network/API?)" >&2
	exit 1
fi

if [[ "${newer}" -eq 1 ]]; then
	echo "check-upstream-pins: one or more pins are behind upstream (advisory only; see BUMP.md)"
else
	echo "check-upstream-pins: pinned tags match latest release tags (or only non-newer)"
fi
exit 0
