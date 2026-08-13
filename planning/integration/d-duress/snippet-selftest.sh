#!/usr/bin/env bash
# Snippet self-test: prove integration build hooks stay PAM-inert.
# Run from anywhere; paths resolve relative to this file / repo root.
#
# Exit 0 = snippets do not enable pam_duress or write /etc/pam.d.
# Exit 1 = regression (would brick “assets only” packaging intent).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT"
HERE="planning/integration/d-duress"

fail() {
	echo "FAIL: $*" >&2
	FAILED=1
}

ok() {
	echo "OK: $*"
}

FAILED=0

echo "== snippet-selftest (repo: $ROOT) =="

BUILD="$HERE/build.sh.snippet"
CF="$HERE/Containerfile.snippet"

for f in "$BUILD" "$CF"; do
	if [[ -f "$f" ]]; then
		ok "exists $f"
	else
		fail "missing $f"
	fi
done

# --- build.sh.snippet ---
if [[ -f "$BUILD" ]]; then
	# No active (non-comment) paths under /etc/pam.d
	if grep -vE '^\s*#|^\s*$' "$BUILD" | grep -nE '/etc/pam\.d' >/dev/null 2>&1; then
		fail "$BUILD has active /etc/pam.d reference"
		grep -vE '^\s*#|^\s*$' "$BUILD" | grep -nE '/etc/pam\.d' >&2 || true
	else
		ok "$BUILD: no active /etc/pam.d paths"
	fi

	# No active auth lines enabling pam_duress
	if grep -vE '^\s*#|^\s*$' "$BUILD" | grep -nE 'pam_duress\.so' >/dev/null 2>&1; then
		fail "$BUILD has active pam_duress.so reference"
	else
		ok "$BUILD: no active pam_duress.so enablement"
	fi

	# Must not install/cp into live PAM stacks (belt + suspenders)
	if grep -vE '^\s*#|^\s*$' "$BUILD" | grep -nE '(cp|install|tee|cat)\s+.*/etc/pam\.d' >/dev/null 2>&1; then
		fail "$BUILD appears to write into /etc/pam.d"
	else
		ok "$BUILD: no write tools targeting /etc/pam.d"
	fi

	# Explicit off-by-default commentary still present
	if grep -qiE 'OFF BY DEFAULT|do NOT touch|DURESS=assets' "$BUILD"; then
		ok "$BUILD: documents OFF BY DEFAULT / assets intent"
	else
		fail "$BUILD missing OFF BY DEFAULT / assets language"
	fi
fi

# --- Containerfile.snippet ---
if [[ -f "$CF" ]]; then
	if grep -vE '^\s*#|^\s*$' "$CF" | grep -nE '/etc/pam\.d' >/dev/null 2>&1; then
		fail "$CF has active /etc/pam.d reference"
		grep -vE '^\s*#|^\s*$' "$CF" | grep -nE '/etc/pam\.d' >&2 || true
	else
		ok "$CF: no active /etc/pam.d paths"
	fi

	if grep -vE '^\s*#|^\s*$' "$CF" | grep -nE 'pam_duress\.so' >/dev/null 2>&1; then
		# COPY of the .so binary path is OK if it's under /usr/lib64 — still check no pam.d
		if grep -vE '^\s*#|^\s*$' "$CF" | grep -nE 'auth[[:space:]].*pam_duress|/etc/pam\.d.*pam_duress' >/dev/null 2>&1; then
			fail "$CF enables pam_duress in PAM stacks"
		else
			ok "$CF: pam_duress.so mentions are non-PAM-stack (binary only)"
		fi
	else
		ok "$CF: no active pam_duress.so lines (or only in comments)"
	fi

	# Forbid RUN sed/cp into pam.d style enablement
	if grep -vE '^\s*#|^\s*$' "$CF" | grep -nE 'sed.*(pam\.d|pam_duress)|cp .*/etc/pam\.d' >/dev/null 2>&1; then
		fail "$CF looks like it rewrites PAM at build time"
	else
		ok "$CF: no sed/cp PAM rewrite patterns"
	fi

	if grep -qiE 'OFF BY DEFAULT|do not|PAM|assets' "$CF"; then
		ok "$CF: documents packaging / PAM stance"
	else
		fail "$CF missing packaging/PAM documentation comments"
	fi
fi

# --- packaging tree must not ship signatures either ---
if find build_files/duress "$HERE" -type f -name '*.sha256' 2>/dev/null | grep -q .; then
	fail "found *.sha256 under packaging paths"
	find build_files/duress "$HERE" -type f -name '*.sha256' -print >&2 || true
else
	ok "no *.sha256 under duress packaging paths"
fi

echo
if [[ "$FAILED" -ne 0 ]]; then
	echo "snippet-selftest: FAILED"
	exit 1
fi
echo "snippet-selftest: PASSED"
exit 0
