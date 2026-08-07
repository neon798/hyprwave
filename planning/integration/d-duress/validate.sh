#!/usr/bin/env bash
# Wave 2+ safety validator for Model D duress packaging.
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
TMPDIR_V="${TMPDIR:-/tmp}/hyprwave-duress-validate-$$"
mkdir -p "$TMPDIR_V"
cleanup() {
	rm -rf "$TMPDIR_V"
}
trap cleanup EXIT

echo "== hyprwave duress validate (repo: $ROOT) =="

# --- required paths ---
for p in \
	build_files/build-duress.sh \
	build_files/duress/hyprwave-duress-setup \
	build_files/duress/README.md \
	build_files/duress/ENABLE.md \
	build_files/duress/THREAT-MODEL.md \
	build_files/duress/templates/00-wipe-sensitive.sh \
	build_files/duress/templates/10-clear-histories.sh \
	build_files/duress/templates/20-local-only-clear.sh \
	planning/integration/d-duress/build.sh.snippet \
	planning/integration/d-duress/Containerfile.snippet \
	planning/integration/d-duress/ENABLE.md \
	planning/integration/d-duress/DRILL.md; do
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

# --- no pre-signed secrets in-tree (entire exclusive packaging areas) ---
if find build_files/duress planning/integration/d-duress -type f -name '*.sha256' 2>/dev/null | grep -q .; then
	fail "found *.sha256 under duress packaging paths (must not ship signatures)"
	find build_files/duress planning/integration/d-duress -type f -name '*.sha256' -print >&2
else
	ok "no *.sha256 under build_files/duress or planning/integration/d-duress"
fi

# --- build snippet must not rewrite live PAM stacks ---
# Allow documentation mentions of pam.d paths; forbid install/cp/cat redirects into /etc/pam.d
if grep -nE '(/etc/pam\.d/|pam\.d/system-auth|pam\.d/sddm)' planning/integration/d-duress/build.sh.snippet |
	grep -vE '^\s*#|Explicitly do NOT|do NOT touch|OFF BY DEFAULT|documentation' |
	grep -nE '(>|>>|tee |cp |install |cat >|cat >>)' >"$TMPDIR_V/duress-pam-grep.out" 2>/dev/null; then
	fail "build.sh.snippet appears to write into pam.d"
	cat "$TMPDIR_V/duress-pam-grep.out" >&2 || true
else
	ok "build.sh.snippet does not write pam.d (comment-only references allowed)"
fi

# Stronger: no uncommented lines that write pam.d
if grep -vE '^\s*#' planning/integration/d-duress/build.sh.snippet |
	grep -nE '/etc/pam\.d' >"$TMPDIR_V/duress-pam-active.out" 2>/dev/null; then
	fail "active (non-comment) /etc/pam.d reference in build.sh.snippet"
	cat "$TMPDIR_V/duress-pam-active.out" >&2 || true
else
	ok "no active /etc/pam.d paths in build.sh.snippet"
fi

# --- snippets that document defaults must not prescribe required pam_duress ---
# PAM reference snippets: no active (non-comment) "required pam_duress.so" lines.
# Docs may warn about required; they must not claim it is the stock/default path.
snippet_required_fail=0
while IFS= read -r -d '' snip; do
	if grep -vE '^\s*#' "$snip" | grep -nE '^[[:space:]]*auth[[:space:]]+required[[:space:]]+pam_duress\.so|[[:space:]]required[[:space:]]+pam_duress\.so' >"$TMPDIR_V/req.out" 2>/dev/null; then
		# Allow pure documentation prose lines that are not PAM auth stanzas
		if grep -vE '^\s*#' "$snip" | grep -nE '^auth[[:space:]]+required[[:space:]]+pam_duress\.so' >"$TMPDIR_V/req2.out" 2>/dev/null; then
			fail "snippet $snip has active 'auth required pam_duress.so' (defaults must use sufficient)"
			cat "$TMPDIR_V/req2.out" >&2 || true
			snippet_required_fail=1
		fi
	fi
done < <(find build_files/duress/pam.d -type f -name '*.snippet' -print0 2>/dev/null)

# integration build snippets: no required pam_duress as installable default
while IFS= read -r -d '' snip; do
	if grep -vE '^\s*#' "$snip" | grep -nE '^auth[[:space:]]+required[[:space:]]+pam_duress\.so' >"$TMPDIR_V/req3.out" 2>/dev/null; then
		fail "snippet $snip has active auth required pam_duress"
		cat "$TMPDIR_V/req3.out" >&2 || true
		snippet_required_fail=1
	fi
done < <(find planning/integration/d-duress -type f -name '*.snippet' -print0 2>/dev/null)

# Docs: forbid framing required as the default enable recommendation
for doc in build_files/duress/ENABLE.md build_files/duress/README.md \
	planning/integration/d-duress/ENABLE.md planning/integration/d-duress/README.md; do
	[[ -f "$doc" ]] || continue
	if grep -qiE 'default[[:space:]]+(is[[:space:]]+)?required[[:space:]]+pam_duress|use[[:space:]]+required[[:space:]]+pam_duress[[:space:]]+by[[:space:]]+default' "$doc"; then
		fail "$doc frames required pam_duress as default"
		snippet_required_fail=1
	fi
done

if [[ "$snippet_required_fail" -eq 0 ]]; then
	ok "no default/required pam_duress prescriptions in snippets/docs"
fi

# ENABLE docs must prefer sufficient and warn on required
for f in build_files/duress/ENABLE.md planning/integration/d-duress/ENABLE.md; do
	if grep -qiE 'sufficient' "$f" && grep -qiE 'required' "$f"; then
		ok "ENABLE mentions sufficient and required caution in $f"
	else
		fail "ENABLE should discuss sufficient vs required: $f"
	fi
done

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

# Pin present + PAM_DURESS_COMMIT env override documented
if grep -qE 'PAM_DURESS_COMMIT=.*[0-9a-f]{40}' build_files/build-duress.sh; then
	ok "PAM_DURESS_COMMIT pinned to full SHA"
else
	fail "PAM_DURESS_COMMIT not a full 40-char SHA"
fi
if grep -q 'PAM_DURESS_COMMIT' build_files/build-duress.sh &&
	grep -qE 'BUMP|Optional env override|override' build_files/build-duress.sh; then
	ok "build-duress documents PAM_DURESS_COMMIT override (BUMP-style)"
else
	fail "build-duress missing BUMP/override docs for PAM_DURESS_COMMIT"
fi
# Prints pin + date
if grep -qE 'pin=\$\{PAM_DURESS_COMMIT\}|pin=\$\{PAM_DURESS_COMMIT\}|build-duress: pin=' build_files/build-duress.sh &&
	grep -qE 'build-duress: date=|BUILD_DATE_UTC' build_files/build-duress.sh; then
	ok "build-duress prints pin + date"
else
	fail "build-duress should echo pin and date"
fi

# OFF BY DEFAULT messaging present
for f in build_files/duress/README.md build_files/duress/ENABLE.md planning/integration/d-duress/ENABLE.md; do
	if grep -qiE 'OFF BY DEFAULT|Default: OFF|PAM is OFF' "$f"; then
		ok "off-by-default language in $f"
	else
		fail "missing OFF BY DEFAULT language in $f"
	fi
done

# Threat model content guards
if grep -qiE 'non-goal|out of scope' build_files/duress/THREAT-MODEL.md &&
	grep -qiE 'LUKS|forensic' build_files/duress/THREAT-MODEL.md; then
	ok "THREAT-MODEL covers non-goals (LUKS/forensics)"
else
	fail "THREAT-MODEL incomplete (need non-goals LUKS/forensics)"
fi

# Templates documented severity markers
if grep -q 'AGGRESSIVE\|aggressive' build_files/duress/templates/00-wipe-sensitive.sh build_files/duress/README.md 2>/dev/null; then
	ok "aggressive wipe labeled"
else
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
if grep -qi 'MILD' build_files/duress/templates/20-local-only-clear.sh &&
	grep -q 'local-only\|local clear\|local-clear\|20-local-only' build_files/duress/README.md; then
	ok "local-only clear template labeled and documented"
else
	fail "20-local-only-clear missing MILD label or README entry"
fi
# local-only must stay under a single cache root
if grep -q 'CACHE_ROOT' build_files/duress/templates/20-local-only-clear.sh &&
	grep -q '\.cache' build_files/duress/templates/20-local-only-clear.sh; then
	ok "local-only template uses single ~/.cache root"
else
	fail "local-only template must constrain to ~/.cache"
fi

# setup tool flags
if grep -q -- '--dry-run' build_files/duress/hyprwave-duress-setup; then
	ok "setup supports --dry-run"
else
	fail "setup missing --dry-run"
fi
if grep -q -- '--verify' build_files/duress/hyprwave-duress-setup &&
	grep -q 'cmd_verify' build_files/duress/hyprwave-duress-setup; then
	ok "setup supports --verify"
else
	fail "setup missing --verify"
fi
if grep -q -- '--local-clear-template' build_files/duress/hyprwave-duress-setup; then
	ok "setup supports --local-clear-template"
else
	fail "setup missing --local-clear-template"
fi

# functional dry-run (no duress_sign required)
export HYPRWAVE_DURESS_TEMPLATE_DIR="$ROOT/build_files/duress/templates"
if bash build_files/duress/hyprwave-duress-setup --version | grep -q .; then
	ok "setup --version runs"
else
	fail "setup --version failed"
fi
if bash build_files/duress/hyprwave-duress-setup --status >"$TMPDIR_V/duress-status.out" 2>&1; then
	ok "setup --status runs"
else
	fail "setup --status failed"
	cat "$TMPDIR_V/duress-status.out" >&2 || true
fi
if bash build_files/duress/hyprwave-duress-setup --status --json 2>/dev/null | grep -q '"pam_enabled"'; then
	ok "setup --status --json runs"
else
	fail "setup --status --json failed"
fi
if bash build_files/duress/hyprwave-duress-setup --dry-run --mild-template >"$TMPDIR_V/duress-dry.out" 2>"$TMPDIR_V/duress-dry.err"; then
	if grep -qi 'dry-run' "$TMPDIR_V/duress-dry.err"; then
		ok "setup --dry-run --mild-template previews"
	else
		fail "setup --dry-run --mild-template did not print dry-run on stderr"
		cat "$TMPDIR_V/duress-dry.err" >&2 || true
	fi
else
	fail "setup --dry-run --mild-template exited non-zero"
	cat "$TMPDIR_V/duress-dry.err" >&2 || true
fi
if bash build_files/duress/hyprwave-duress-setup --dry-run --local-clear-template >"$TMPDIR_V/duress-dry2.out" 2>"$TMPDIR_V/duress-dry2.err"; then
	if grep -qi 'dry-run' "$TMPDIR_V/duress-dry2.err"; then
		ok "setup --dry-run --local-clear-template previews"
	else
		fail "setup --dry-run --local-clear-template did not print dry-run on stderr"
	fi
else
	fail "setup --dry-run --local-clear-template exited non-zero"
	cat "$TMPDIR_V/duress-dry2.err" >&2 || true
fi

# --- --verify dry paths (read-only; no duress_sign) ---
VERIFY_EMPTY="$TMPDIR_V/empty-duress"
VERIFY_BAD="$TMPDIR_V/bad-duress"
VERIFY_OK="$TMPDIR_V/ok-duress"
mkdir -p "$VERIFY_EMPTY" "$VERIFY_BAD" "$VERIFY_OK"

# empty dir => OK
if bash build_files/duress/hyprwave-duress-setup --verify "$VERIFY_EMPTY" >"$TMPDIR_V/v-empty.out" 2>&1; then
	ok "setup --verify empty dir exits 0"
else
	fail "setup --verify empty dir should exit 0"
	cat "$TMPDIR_V/v-empty.out" >&2 || true
fi

# script without signature => FAIL
printf '%s\n' '#!/bin/sh' 'exit 0' >"$VERIFY_BAD/nosig.sh"
chmod 500 "$VERIFY_BAD/nosig.sh"
if bash build_files/duress/hyprwave-duress-setup --verify "$VERIFY_BAD" >"$TMPDIR_V/v-bad.out" 2>&1; then
	fail "setup --verify should fail when .sha256 missing"
	cat "$TMPDIR_V/v-bad.out" >&2 || true
else
	ok "setup --verify detects missing .sha256"
fi

# script with matching .sha256 name + good mode => OK (content of sig not validated without crypto)
printf '%s\n' '#!/bin/sh' 'exit 0' >"$VERIFY_OK/signed.sh"
chmod 500 "$VERIFY_OK/signed.sh"
echo "placeholder-not-a-real-signature" >"$VERIFY_OK/signed.sh.sha256"
chmod 400 "$VERIFY_OK/signed.sh.sha256"
if bash build_files/duress/hyprwave-duress-setup --verify "$VERIFY_OK" >"$TMPDIR_V/v-ok.out" 2>&1; then
	ok "setup --verify accepts mode+matching .sha256 presence"
else
	fail "setup --verify should pass for mode 500 + present .sha256"
	cat "$TMPDIR_V/v-ok.out" >&2 || true
fi

if bash build_files/duress/hyprwave-duress-setup --verify "$VERIFY_OK" --json 2>/dev/null | grep -q '"read_only"'; then
	ok "setup --verify --json runs"
else
	# flag order: --json before --verify
	if bash build_files/duress/hyprwave-duress-setup --json --verify "$VERIFY_OK" 2>/dev/null | grep -q '"read_only"'; then
		ok "setup --json --verify runs"
	else
		fail "setup --verify --json failed"
	fi
fi

# ensure dry-run / verify fixtures did not create signatures in repo packaging tree
if find build_files/duress planning/integration/d-duress -name '*.sha256' 2>/dev/null | grep -q .; then
	fail "validate left .sha256 under packaging tree"
else
	ok "no signatures leaked into packaging tree"
fi

# DRILL.md present with VM procedure markers
if grep -qiE 'disposable|Phase|30|45' planning/integration/d-duress/DRILL.md; then
	ok "DRILL.md looks like operator procedure"
else
	fail "DRILL.md missing procedure markers"
fi

# Recovery language in ENABLE
if grep -qiE 'locked out|Recovery' build_files/duress/ENABLE.md planning/integration/d-duress/ENABLE.md; then
	ok "ENABLE docs cover lockout recovery"
else
	fail "ENABLE missing recovery-if-locked-out"
fi

echo
if [[ "$FAILED" -ne 0 ]]; then
	echo "RESULT: FAILED"
	exit 1
fi
echo "RESULT: PASSED"
exit 0
