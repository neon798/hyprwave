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

# Active (non-comment) install/copy of pam snippets into live /etc/pam.d.
# Share-only destinations under /usr/share/hyprwave/duress/pam.d are fine.
active_pam_snippet_to_etc() {
	local f="$1"
	[[ -f "$f" ]] || return 1
	if grep -vE '^\s*#|^\s*$' "$f" |
		grep -nE '(^|[[:space:]])(cp|install|rsync|tee|cat)([[:space:]].*)?/etc/pam\.d' >/dev/null 2>&1; then
		return 0
	fi
	if grep -vE '^\s*#|^\s*$' "$f" |
		grep -nE '(cp|install|rsync)[[:space:]].*pam\.d.*/etc/pam\.d' >/dev/null 2>&1; then
		return 0
	fi
	if grep -vE '^\s*#|^\s*$' "$f" |
		grep -nE 'install[[:space:]].+/etc/pam\.d/' >/dev/null 2>&1; then
		return 0
	fi
	return 1
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
	# D-W3-001: must not copy reference pam.d snippets onto live stacks
	if active_pam_snippet_to_etc "$BUILD"; then
		fail "$BUILD would install/copy pam snippets into /etc/pam.d"
	else
		ok "$BUILD: pam snippets not installed into /etc/pam.d"
	fi

	# Explicit off-by-default commentary still present
	if grep -qiE 'OFF BY DEFAULT|do NOT touch|DURESS=assets' "$BUILD"; then
		ok "$BUILD: documents OFF BY DEFAULT / assets intent"
	else
		fail "$BUILD missing OFF BY DEFAULT / assets language"
	fi

	# Reference PAM snippets may only land under /usr/share/.../pam.d (docs),
	# never under /etc/pam.d (live stacks).
	if grep -vE '^\s*#|^\s*$' "$BUILD" | grep -nE '(/etc/pam\.d/|cp\s+-a\s+.*/pam\.d|install\s+.*/pam\.d)' |
		grep -vE '/usr/share/hyprwave/duress/pam\.d' >/dev/null 2>&1; then
		# Allow only installs whose destination is under share/hyprwave/duress/pam.d
		if grep -vE '^\s*#|^\s*$' "$BUILD" | grep -nE '(/etc/pam\.d|/etc/pam\.d/)' >/dev/null 2>&1; then
			fail "$BUILD installs or references live /etc/pam.d (snippets must stay under /usr/share)"
		fi
	fi
	if grep -vE '^\s*#|^\s*$' "$BUILD" | grep -E '/usr/share/hyprwave/duress/pam\.d' >/dev/null 2>&1; then
		ok "$BUILD: reference pam.d snippets target /usr/share/hyprwave/duress/pam.d only"
	else
		# still OK if no pam.d deploy at all, but stock snippet should document share path
		if grep -qE 'pam\.d' "$BUILD"; then
			fail "$BUILD mentions pam.d but not the share-only install path"
		else
			ok "$BUILD: no pam.d deploy block (still inert)"
		fi
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

# --- live build.sh (if present after merge) must also stay PAM-inert ---
# Read-only audit: Model D may not edit production build.sh on this lane, but
# packaging safety must still fail if someone lands a PAM enable regress.
LIVE_BUILD="build_files/build.sh"
if [[ -f "$LIVE_BUILD" ]]; then
	if grep -vE '^\s*#|^\s*$' "$LIVE_BUILD" | grep -nE '/etc/pam\.d' >/dev/null 2>&1; then
		fail "$LIVE_BUILD has active /etc/pam.d reference"
		grep -vE '^\s*#|^\s*$' "$LIVE_BUILD" | grep -nE '/etc/pam\.d' >&2 || true
	else
		ok "$LIVE_BUILD: no active /etc/pam.d paths"
	fi
	# Must not install reference snippets into live stacks
	if grep -vE '^\s*#|^\s*$' "$LIVE_BUILD" | grep -nE '(cp|install|tee)\s+.*/etc/pam\.d' >/dev/null 2>&1; then
		fail "$LIVE_BUILD appears to write into /etc/pam.d"
	else
		ok "$LIVE_BUILD: no write tools targeting /etc/pam.d"
	fi
	if active_pam_snippet_to_etc "$LIVE_BUILD"; then
		fail "$LIVE_BUILD would install/copy pam snippets into /etc/pam.d"
	else
		ok "$LIVE_BUILD: pam snippets not installed into /etc/pam.d"
	fi
	# pam.d docs deploy only under share (when present)
	if grep -vE '^\s*#|^\s*$' "$LIVE_BUILD" | grep -E 'duress/pam\.d' >/dev/null 2>&1; then
		if grep -vE '^\s*#|^\s*$' "$LIVE_BUILD" | grep -E '/usr/share/hyprwave/duress/pam\.d' >/dev/null 2>&1; then
			ok "$LIVE_BUILD: duress pam.d snippets install under /usr/share only"
		else
			fail "$LIVE_BUILD: duress pam.d deploy missing share path"
		fi
	fi
	if grep -qiE 'OFF BY DEFAULT|no PAM enable' "$LIVE_BUILD"; then
		ok "$LIVE_BUILD: documents duress OFF BY DEFAULT"
	else
		fail "$LIVE_BUILD missing duress OFF BY DEFAULT language near packaging block"
	fi
else
	ok "live build.sh not present (snippet-only checkout)"
fi

# --- negative fixtures (temp): prove helper catches snippet→/etc/pam.d ---
NEG_ST="${TMPDIR:-/tmp}/hyprwave-snippet-selftest-$$"
mkdir -p "$NEG_ST"
trap 'rm -rf "$NEG_ST"' EXIT
printf '%s\n' \
	'cp -a /ctx/duress/pam.d/. /etc/pam.d/' \
	>"$NEG_ST/bad-cp-snippets.sh"
if active_pam_snippet_to_etc "$NEG_ST/bad-cp-snippets.sh"; then
	ok "negative: cp pam.d → /etc/pam.d detected"
else
	fail "negative: cp pam.d → /etc/pam.d NOT detected"
fi
printf '%s\n' \
	'install -m0644 /ctx/duress/pam.d/x.snippet /etc/pam.d/system-auth' \
	>"$NEG_ST/bad-install-snippet.sh"
if active_pam_snippet_to_etc "$NEG_ST/bad-install-snippet.sh"; then
	ok "negative: install snippet → /etc/pam.d detected"
else
	fail "negative: install snippet → /etc/pam.d NOT detected"
fi
printf '%s\n' \
	'cp -a /ctx/duress/pam.d/. /usr/share/hyprwave/duress/pam.d/' \
	>"$NEG_ST/ok-share.sh"
if active_pam_snippet_to_etc "$NEG_ST/ok-share.sh"; then
	fail "negative: share-only deploy wrongly flagged"
else
	ok "negative: share-only pam.d deploy allowed"
fi
rm -rf "$NEG_ST"
trap - EXIT

echo
if [[ "$FAILED" -ne 0 ]]; then
	echo "snippet-selftest: FAILED"
	exit 1
fi
echo "snippet-selftest: PASSED"
exit 0
