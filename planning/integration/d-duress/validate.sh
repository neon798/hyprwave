#!/usr/bin/env bash
# Wave 2 safety validator for Model D duress packaging.
# Run from repo root (or any cwd); resolves paths relative to this file.
#
# Exit 0 = OK. Exit 1 = packaging safety regression.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT"

fail() {
	echo "FAIL: $*" >&2
	FAILED=1
}

ok() {
	echo "OK: $*"
}

FAILED=0

echo "== hyprwave duress validate (repo: $ROOT) =="

# --- required paths ---
for p in \
	build_files/build-duress.sh \
	build_files/duress/hyprwave-duress-setup \
	build_files/duress/README.md \
	build_files/duress/ENABLE.md \
	build_files/duress/templates/00-wipe-sensitive.sh \
	build_files/duress/templates/10-clear-histories.sh \
	planning/integration/d-duress/build.sh.snippet \
	planning/integration/d-duress/Containerfile.snippet \
	planning/integration/d-duress/ENABLE.md; do
	if [[ -f "$p" ]]; then
		ok "exists $p"
	else
		fail "missing $p"
	fi
done

# --- syntax ---
if bash -n build_files/build-duress.sh; then
	ok "bash -n build-duress.sh"
else
	fail "bash -n build-duress.sh"
fi

if bash -n build_files/duress/hyprwave-duress-setup; then
	ok "bash -n hyprwave-duress-setup"
else
	fail "bash -n hyprwave-duress-setup"
fi

shopt -s nullglob
for t in build_files/duress/templates/*.sh; do
	if bash -n "$t" && sh -n "$t"; then
		ok "bash/sh -n $t"
	else
		fail "syntax $t"
	fi
done
shopt -u nullglob

if bash -n planning/integration/d-duress/validate.sh; then
	ok "bash -n validate.sh"
else
	fail "bash -n validate.sh"
fi

# --- no pre-signed secrets in-tree ---
if find build_files/duress -type f -name '*.sha256' 2>/dev/null | grep -q .; then
	fail "found *.sha256 under build_files/duress (must not ship signatures)"
	find build_files/duress -type f -name '*.sha256' -print >&2
else
	ok "no *.sha256 under build_files/duress"
fi

# --- build snippet must not rewrite live PAM stacks ---
# Allow documentation mentions of pam.d paths; forbid install/cp/cat redirects into /etc/pam.d
if grep -nE '(/etc/pam\.d/|pam\.d/system-auth|pam\.d/sddm)' planning/integration/d-duress/build.sh.snippet |
	grep -vE '^\s*#|Explicitly do NOT|do NOT touch|OFF BY DEFAULT|documentation' |
	grep -nE '(>|>>|tee |cp |install |cat >|cat >>)' >/tmp/duress-pam-grep.out 2>/dev/null; then
	fail "build.sh.snippet appears to write into pam.d"
	cat /tmp/duress-pam-grep.out >&2 || true
else
	ok "build.sh.snippet does not write pam.d (comment-only references allowed)"
fi

# Stronger: no uncommented lines that write pam.d
if grep -vE '^\s*#' planning/integration/d-duress/build.sh.snippet |
	grep -nE '/etc/pam\.d' >/tmp/duress-pam-active.out 2>/dev/null; then
	fail "active (non-comment) /etc/pam.d reference in build.sh.snippet"
	cat /tmp/duress-pam-active.out >&2 || true
else
	ok "no active /etc/pam.d paths in build.sh.snippet"
fi

# --- build-duress must not install into host PAM without DESTROOT ---
if grep -nE 'make install' build_files/build-duress.sh | grep -v '^\s*#' | grep -q .; then
	# make install to host is discouraged; we stage with install -m
	if grep -nE 'make install' build_files/build-duress.sh | grep -v DESTROOT | grep -v '#'; then
		fail "build-duress.sh may call bare make install"
	fi
else
	ok "build-duress.sh does not use bare make install"
fi

# Must stage to DESTROOT
if grep -q 'DESTROOT' build_files/build-duress.sh; then
	ok "build-duress.sh uses DESTROOT staging"
else
	fail "build-duress.sh missing DESTROOT"
fi

# Pin present
if grep -qE 'PAM_DURESS_COMMIT=.*[0-9a-f]{40}' build_files/build-duress.sh; then
	ok "PAM_DURESS_COMMIT pinned to full SHA"
else
	fail "PAM_DURESS_COMMIT not a full 40-char SHA"
fi

# OFF BY DEFAULT messaging present
for f in build_files/duress/README.md build_files/duress/ENABLE.md planning/integration/d-duress/ENABLE.md; do
	if grep -qiE 'OFF BY DEFAULT|Default: OFF|PAM is OFF' "$f"; then
		ok "off-by-default language in $f"
	else
		fail "missing OFF BY DEFAULT language in $f"
	fi
done

# Templates documented severity markers
if grep -q 'AGGRESSIVE\|aggressive' build_files/duress/templates/00-wipe-sensitive.sh build_files/duress/README.md 2>/dev/null; then
	ok "aggressive wipe labeled"
else
	# 00 template may only say DESTROYS — README must label
	if grep -qi 'aggressive\|AGGRESSIVE' build_files/duress/README.md; then
		ok "aggressive labeled in README"
	else
		fail "aggressive template not labeled in README"
	fi
fi
if grep -qi 'MILD' build_files/duress/templates/10-clear-histories.sh; then
	ok "mild template labeled"
else
	fail "mild template missing MILD label"
fi

# setup tool dry-run flag exists
if grep -q -- '--dry-run' build_files/duress/hyprwave-duress-setup; then
	ok "setup supports --dry-run"
else
	fail "setup missing --dry-run"
fi

# functional dry-run (no duress_sign required)
export HYPRWAVE_DURESS_TEMPLATE_DIR="$ROOT/build_files/duress/templates"
if bash build_files/duress/hyprwave-duress-setup --version | grep -q .; then
	ok "setup --version runs"
else
	fail "setup --version failed"
fi
if bash build_files/duress/hyprwave-duress-setup --status >/tmp/duress-status.out 2>&1; then
	ok "setup --status runs"
else
	fail "setup --status failed"
	cat /tmp/duress-status.out >&2 || true
fi
if bash build_files/duress/hyprwave-duress-setup --status --json 2>/dev/null | grep -q '"pam_enabled"'; then
	ok "setup --status --json runs"
else
	fail "setup --status --json failed"
fi
if bash build_files/duress/hyprwave-duress-setup --dry-run --mild-template >/tmp/duress-dry.out 2>/tmp/duress-dry.err; then
	if grep -qi 'dry-run' /tmp/duress-dry.err; then
		ok "setup --dry-run --mild-template previews"
	else
		fail "setup --dry-run --mild-template did not print dry-run on stderr"
		cat /tmp/duress-dry.err >&2 || true
	fi
else
	fail "setup --dry-run --mild-template exited non-zero"
	cat /tmp/duress-dry.err >&2 || true
fi

# ensure dry-run did not create signatures in repo
if find build_files/duress -name '*.sha256' | grep -q .; then
	fail "dry-run left .sha256 under build_files/duress"
else
	ok "dry-run left no signatures in packaging tree"
fi

echo
if [[ "$FAILED" -ne 0 ]]; then
	echo "RESULT: FAILED"
	exit 1
fi
echo "RESULT: PASSED"
exit 0
