#!/usr/bin/env bash
# ghcr-pull-test.sh — anonymous GHCR reachability for Hyprwave images
#
# Usage:
#   bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh
#   bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh --owner neon798
#   OWNER=neon798 TAG=latest bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh
#
# Environment:
#   OWNER   — GHCR namespace (default: neon798)
#   TAG     — image tag (default: latest). Prefer YYYYMMDD for non-floating checks.
#
# Exit codes:
#   0 — both hyprwave and hyprwave-cosmic are pullable (or inspectable) anonymously
#   1 — one or both failed (private package, missing tag, network)
#   2 — bad args / missing tools
#
# Does not require or use any secrets. Does not push. Safe for CI smoke.

set -euo pipefail

OWNER="${OWNER:-neon798}"
TAG="${TAG:-latest}"
TOOL=""

usage() {
	sed -n '2,22p' "$0" | sed 's/^# \?//'
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--help | -h)
		usage
		exit 0
		;;
	--owner)
		OWNER="${2:-}"
		shift 2
		;;
	--tag)
		TAG="${2:-}"
		shift 2
		;;
	*)
		echo "ERROR: unknown arg: $1 (try --help)" >&2
		exit 2
		;;
	esac
done

if [[ -z "${OWNER}" || -z "${TAG}" ]]; then
	echo "ERROR: OWNER and TAG must be non-empty" >&2
	exit 2
fi

if command -v skopeo >/dev/null 2>&1; then
	TOOL=skopeo
elif command -v podman >/dev/null 2>&1; then
	TOOL=podman
elif command -v docker >/dev/null 2>&1; then
	TOOL=docker
else
	echo "ERROR: need skopeo, podman, or docker installed to probe GHCR" >&2
	exit 2
fi

# Empty auth file so host logins do not masquerade as "anonymous" success.
AUTHFILE="$(mktemp "${TMPDIR:-/tmp}/ghcr-pull-test-auth.XXXXXX")"
echo '{}' >"${AUTHFILE}"
cleanup_auth() {
	rm -f "${AUTHFILE}" /tmp/ghcr-pull-test.out /tmp/ghcr-pull-test.err 2>/dev/null || true
}
trap cleanup_auth EXIT

IMAGES=(
	"ghcr.io/${OWNER}/hyprwave:${TAG}"
	"ghcr.io/${OWNER}/hyprwave-cosmic:${TAG}"
)

echo "Tool:  ${TOOL}"
echo "Owner: ${OWNER}"
echo "Tag:   ${TAG}"
echo "Mode:  anonymous inspect/pull (empty authfile; no secrets)"
echo "---"

fail=0

probe() {
	local ref="$1"
	echo "PROBE ${ref}"
	case "${TOOL}" in
	skopeo)
		# inspect does not leave a local image; best for CI smoke
		if skopeo inspect --authfile "${AUTHFILE}" "docker://${ref}" \
			>/tmp/ghcr-pull-test.out 2>/tmp/ghcr-pull-test.err; then
			digest=""
			if command -v jq >/dev/null 2>&1; then
				digest="$(jq -r '.Digest // empty' /tmp/ghcr-pull-test.out 2>/dev/null || true)"
			fi
			echo "OK    ${ref}${digest:+  (${digest})}"
		else
			echo "FAIL  ${ref}"
			sed 's/^/      /' /tmp/ghcr-pull-test.err >&2 || true
			fail=1
		fi
		;;
	podman)
		# Prefer manifest inspect; fall back to pull. Always pass empty authfile.
		if podman manifest inspect --authfile "${AUTHFILE}" "${ref}" \
			>/tmp/ghcr-pull-test.out 2>/tmp/ghcr-pull-test.err; then
			echo "OK    ${ref} (manifest inspect)"
		elif podman pull --authfile "${AUTHFILE}" "${ref}" \
			>/tmp/ghcr-pull-test.out 2>/tmp/ghcr-pull-test.err; then
			echo "OK    ${ref} (pull)"
		else
			echo "FAIL  ${ref}"
			sed 's/^/      /' /tmp/ghcr-pull-test.err >&2 || true
			fail=1
		fi
		;;
	docker)
		# docker does not take --authfile the same way; use isolated config dir
		local cfg
		cfg="$(mktemp -d "${TMPDIR:-/tmp}/ghcr-pull-test-docker.XXXXXX")"
		if DOCKER_CONFIG="${cfg}" docker manifest inspect "${ref}" \
			>/tmp/ghcr-pull-test.out 2>/tmp/ghcr-pull-test.err; then
			echo "OK    ${ref} (manifest inspect)"
		elif DOCKER_CONFIG="${cfg}" docker pull "${ref}" \
			>/tmp/ghcr-pull-test.out 2>/tmp/ghcr-pull-test.err; then
			echo "OK    ${ref} (pull)"
		else
			echo "FAIL  ${ref}"
			sed 's/^/      /' /tmp/ghcr-pull-test.err >&2 || true
			fail=1
		fi
		rm -rf "${cfg}"
		;;
	esac
}

for img in "${IMAGES[@]}"; do
	probe "${img}"
done

echo "---"
if [[ "${fail}" -ne 0 ]]; then
	cat <<'EOF' >&2
ghcr-pull-test: FAILED

Likely causes:
  - GHCR package visibility is private (GitHub → Packages → package settings → Public)
  - Image never pushed for this owner/tag (check Actions build_push on default branch)
  - Network / GHCR outage

See: planning/integration/a-stabilize/RELEASE.md (GHCR visibility)
     planning/integration/a-stabilize/CI-MATRIX.md
EOF
	exit 1
fi

echo "ghcr-pull-test: both images reachable anonymously"
exit 0
