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
	planning/integration/d-duress/DRILL.md \
	planning/integration/d-duress/FAQ.md \
	planning/integration/d-duress/OPERATOR-RUNBOOK.md \
	planning/integration/d-duress/SIGNING.md \
	planning/integration/d-duress/RESIDUALS.md \
	planning/integration/d-duress/INTEGRATOR-CHECKLIST.md \
	planning/integration/d-duress/INTEGRATION-DAY.md \
	planning/integration/d-duress/snippet-selftest.sh; do
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

if bash -n planning/integration/d-duress/snippet-selftest.sh; then
	ok "bash -n snippet-selftest.sh"
else
	fail "bash -n snippet-selftest.sh"
fi

# --- snippet self-test (PAM-inert build hooks) ---
if bash planning/integration/d-duress/snippet-selftest.sh >"$TMPDIR_V/snippet-selftest.out" 2>&1; then
	ok "snippet-selftest.sh PASSED"
else
	fail "snippet-selftest.sh FAILED"
	cat "$TMPDIR_V/snippet-selftest.out" >&2 || true
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

# DRILL.md present with VM procedure markers + image-path rehearsal (no PAM enable)
if grep -qiE 'disposable|Phase|30|45' planning/integration/d-duress/DRILL.md; then
	ok "DRILL.md looks like operator procedure"
else
	fail "DRILL.md missing procedure markers"
fi
if grep -q '/usr/bin/hyprwave-duress-setup' planning/integration/d-duress/DRILL.md &&
	grep -q '/usr/share/hyprwave/duress' planning/integration/d-duress/DRILL.md &&
	grep -q '/etc/duress.d' planning/integration/d-duress/DRILL.md &&
	grep -q '/usr/lib64/security/pam_duress.so' planning/integration/d-duress/DRILL.md; then
	ok "DRILL.md documents real image paths (/usr/bin setup, share, /etc/duress.d, module)"
else
	fail "DRILL.md missing real image path inventory"
fi
if grep -qiE 'rehearsal|REHEARSAL' planning/integration/d-duress/DRILL.md &&
	grep -qiE 'does not|never|do not' planning/integration/d-duress/DRILL.md &&
	grep -qiE 'ENABLE\.md' planning/integration/d-duress/DRILL.md &&
	grep -qiE 'dry-run|--help|--status|--verify' planning/integration/d-duress/DRILL.md; then
	ok "DRILL.md is rehearsal-only (dry-run/help; production enable via ENABLE.md)"
else
	fail "DRILL.md missing rehearsal banner / dry-run scope / ENABLE.md pointer"
fi
# Drill must not prescribe installing pam_duress into live PAM as a drill step
if grep -nE '^\| C[0-9] |^\| B[0-9] |^\| A[0-9] |^\| D[0-9] ' planning/integration/d-duress/DRILL.md |
	grep -iE 'pam\.d|pam_duress\.so' |
	grep -viE 'grep|no pam|Zero|zero|OK:|not |never|without|reference|inventory|enable lines|stock' >/dev/null; then
	fail "DRILL phase table may prescribe PAM enable during drill"
else
	ok "DRILL phase tables stay PAM-inert (inspect/grep only)"
fi

# Recovery language in ENABLE
if grep -qiE 'locked out|Recovery' build_files/duress/ENABLE.md planning/integration/d-duress/ENABLE.md; then
	ok "ENABLE docs cover lockout recovery"
else
	fail "ENABLE missing recovery-if-locked-out"
fi

# FAQ / operator runbook content guards
if [[ -f planning/integration/d-duress/FAQ.md ]]; then
	faq_q=$(grep -cE '^### [0-9]+\.' planning/integration/d-duress/FAQ.md || true)
	if [[ "${faq_q:-0}" -ge 10 ]]; then
		ok "FAQ.md has ≥10 numbered Q&As ($faq_q)"
	else
		fail "FAQ.md needs ≥10 numbered Q&As (found ${faq_q:-0})"
	fi
	if grep -qiE 'OFF|off by default' planning/integration/d-duress/FAQ.md &&
		grep -qiE 'LUKS|forensic' planning/integration/d-duress/FAQ.md &&
		grep -qiE 'bootc|upgrade' planning/integration/d-duress/FAQ.md &&
		grep -qiE 'lockout|locked out|recovery' planning/integration/d-duress/FAQ.md &&
		grep -qiE 'hyprlock|greeter|SDDM' planning/integration/d-duress/FAQ.md; then
		ok "FAQ covers off-by-default, LUKS, bootc, recovery, greeter/hyprlock"
	else
		fail "FAQ missing required topic coverage"
	fi
fi
if [[ -f planning/integration/d-duress/OPERATOR-RUNBOOK.md ]]; then
	if grep -qiE 'enable' planning/integration/d-duress/OPERATOR-RUNBOOK.md &&
		grep -qiE 'disable|rollback|restore' planning/integration/d-duress/OPERATOR-RUNBOOK.md &&
		grep -qiE 'DRILL' planning/integration/d-duress/OPERATOR-RUNBOOK.md &&
		grep -qiE 'disposable|VM' planning/integration/d-duress/OPERATOR-RUNBOOK.md; then
		ok "OPERATOR-RUNBOOK has enable → test → disable/rollback + DRILL link"
	else
		fail "OPERATOR-RUNBOOK incomplete (need enable/test/rollback + DRILL)"
	fi
fi

# SIGNING.md — never commit signatures + dry-run / verify / disposable path
if [[ -f planning/integration/d-duress/SIGNING.md ]]; then
	if grep -qiE 'never.*commit|do not commit|\*\.sha256' planning/integration/d-duress/SIGNING.md &&
		grep -qiE 'duress_sign|--verify|dry-run' planning/integration/d-duress/SIGNING.md &&
		grep -qiE 'disposable|TMPDIR|/tmp/' planning/integration/d-duress/SIGNING.md; then
		ok "SIGNING.md covers no-commit, sign/verify, disposable path"
	else
		fail "SIGNING.md incomplete (need no-commit signatures + verify + lab path)"
	fi
fi

# RESIDUALS.md — operator-owned gaps packaging does not close
if [[ -f planning/integration/d-duress/RESIDUALS.md ]]; then
	if grep -qiE 'LUKS|disk encryption|encryption' planning/integration/d-duress/RESIDUALS.md &&
		grep -qiE 'physical|evil maid|root' planning/integration/d-duress/RESIDUALS.md &&
		grep -qiE 'bootc|PAM drift|drift' planning/integration/d-duress/RESIDUALS.md &&
		grep -qiE 'sign|trust|script' planning/integration/d-duress/RESIDUALS.md; then
		ok "RESIDUALS.md covers LUKS, physical/root, bootc drift, signed-script trust"
	else
		fail "RESIDUALS.md incomplete residual coverage"
	fi
fi

# README severity table matches all three templates + links operator docs
if grep -q '00-wipe-sensitive' build_files/duress/README.md &&
	grep -q '10-clear-histories' build_files/duress/README.md &&
	grep -q '20-local-only-clear' build_files/duress/README.md &&
	grep -qi 'AGGRESSIVE' build_files/duress/README.md &&
	grep -qi 'MILD' build_files/duress/README.md; then
	ok "packaging README severity table lists all templates"
else
	fail "packaging README severity table missing a template"
fi
if grep -q 'SIGNING.md' build_files/duress/README.md &&
	grep -q 'FAQ.md' build_files/duress/README.md &&
	grep -q 'OPERATOR-RUNBOOK.md' build_files/duress/README.md; then
	ok "packaging README links FAQ + OPERATOR-RUNBOOK + SIGNING"
else
	fail "packaging README missing FAQ/OPERATOR-RUNBOOK/SIGNING links"
fi
if grep -q '00-wipe-sensitive' planning/integration/d-duress/README.md &&
	grep -q '10-clear-histories' planning/integration/d-duress/README.md &&
	grep -q '20-local-only-clear' planning/integration/d-duress/README.md &&
	grep -q 'SIGNING.md' planning/integration/d-duress/README.md &&
	grep -q 'RESIDUALS.md' planning/integration/d-duress/README.md; then
	ok "integration README severity table + SIGNING/RESIDUALS index"
else
	fail "integration README missing severity table or SIGNING/RESIDUALS"
fi

# INTEGRATOR-CHECKLIST — ordered freeze path, no accidental enable
if [[ -f planning/integration/d-duress/INTEGRATOR-CHECKLIST.md ]]; then
	if grep -qiE 'do not.*enable|OFF BY DEFAULT|assets only' planning/integration/d-duress/INTEGRATOR-CHECKLIST.md &&
		grep -qiE 'validate\.sh|snippet-selftest' planning/integration/d-duress/INTEGRATOR-CHECKLIST.md &&
		grep -qiE 'ENABLE\.md|OPERATOR-RUNBOOK|SIGNING' planning/integration/d-duress/INTEGRATOR-CHECKLIST.md &&
		grep -qiE 'snippet|Containerfile|build\.sh' planning/integration/d-duress/INTEGRATOR-CHECKLIST.md; then
		ok "INTEGRATOR-CHECKLIST covers merge → no PAM → validate → operator ENABLE docs"
	else
		fail "INTEGRATOR-CHECKLIST incomplete freeze steps"
	fi
fi
# Integration README must index full operator set + checklist
for doc in SIGNING RESIDUALS FAQ OPERATOR-RUNBOOK DRILL INTEGRATOR-CHECKLIST INTEGRATION-DAY; do
	if grep -q "${doc}.md" planning/integration/d-duress/README.md; then
		ok "integration README indexes ${doc}.md"
	else
		fail "integration README missing link/index for ${doc}.md"
	fi
done
if grep -q 'INTEGRATOR-CHECKLIST.md' build_files/duress/README.md; then
	ok "packaging README links INTEGRATOR-CHECKLIST"
else
	fail "packaging README missing INTEGRATOR-CHECKLIST link"
fi
# INTEGRATION-DAY one-page gate card
if [[ -f planning/integration/d-duress/INTEGRATION-DAY.md ]]; then
	if grep -qiE 'INTEGRATOR-CHECKLIST|validate\.sh|snippet-selftest' planning/integration/d-duress/INTEGRATION-DAY.md &&
		grep -qiE 'never.*enable|do \*\*not\*\* enable|Never enable PAM|OFF' planning/integration/d-duress/INTEGRATION-DAY.md &&
		grep -qiE 'SIGNING|\.sha256|do not commit' planning/integration/d-duress/INTEGRATION-DAY.md; then
		ok "INTEGRATION-DAY links checklist/validate and forbids PAM + signature commit"
	else
		fail "INTEGRATION-DAY incomplete gate card"
	fi
fi

# --- negative fixtures (temp dirs; prove policies would catch bad trees) ---
echo "== negative fixtures =="
NEG="$TMPDIR_V/neg-fixtures"
mkdir -p "$NEG/duress" "$NEG/integration" "$NEG/pam.d" "$NEG/buildhook"

# N1: planted *.sha256 must be detected (policy: fail packaging trees that ship signatures)
printf '%s\n' 'not-a-real-signature' >"$NEG/duress/planted-script.sha256"
if find "$NEG/duress" "$NEG/integration" -type f -name '*.sha256' 2>/dev/null | grep -q .; then
	ok "negative: planted *.sha256 is detected (would fail real-tree gate)"
else
	fail "negative: planted *.sha256 was not detected"
fi
# real packaging tree must still be clean (already checked above; re-assert after fixtures)
if find build_files/duress planning/integration/d-duress -type f -name '*.sha256' 2>/dev/null | grep -q .; then
	fail "negative setup polluted real packaging tree with *.sha256"
else
	ok "negative: real packaging tree still has no *.sha256"
fi

# N2: active "auth required pam_duress.so" snippet must be detected as bad default
printf '%s\n' \
	'# bad fixture — must never ship as stock default' \
	'auth       required                   pam_duress.so' \
	>"$NEG/integration/bad-required.snippet"
if grep -vE '^\s*#' "$NEG/integration/bad-required.snippet" |
	grep -qE '^auth[[:space:]]+required[[:space:]]+pam_duress\.so'; then
	ok "negative: active auth required pam_duress is detected (would fail)"
else
	fail "negative: required pam_duress fixture not detected"
fi
# comment-only required mention should NOT trip the active-line check
printf '%s\n' \
	'# Do NOT use: auth required pam_duress.so as default' \
	'auth       sufficient                 pam_duress.so' \
	>"$NEG/integration/ok-sufficient.snippet"
if grep -vE '^\s*#' "$NEG/integration/ok-sufficient.snippet" |
	grep -qE '^auth[[:space:]]+required[[:space:]]+pam_duress\.so'; then
	fail "negative: comment/sufficient fixture wrongly flagged as required"
else
	ok "negative: sufficient + comment-only required is not a hard fail"
fi

# N3: missing THREAT-MODEL must fail presence check
if [[ ! -f "$NEG/duress/THREAT-MODEL.md" ]]; then
	ok "negative: missing THREAT-MODEL detected as absent"
else
	fail "negative: THREAT-MODEL unexpectedly present in empty fixture dir"
fi
if [[ ! -f build_files/duress/THREAT-MODEL.md ]]; then
	fail "real THREAT-MODEL.md missing from packaging tree"
else
	ok "negative: real THREAT-MODEL.md still present"
fi

# N4: build-hook style write into /etc/pam.d must be detected
printf '%s\n' \
	'install -d /usr/share/hyprwave/duress' \
	'cp -a /ctx/duress/templates/. /usr/share/hyprwave/duress/templates/' \
	'cp /tmp/evil /etc/pam.d/system-auth' \
	>"$NEG/buildhook/bad-build.sh.snippet"
if grep -vE '^\s*#' "$NEG/buildhook/bad-build.sh.snippet" |
	grep -nE '/etc/pam\.d' |
	grep -nE '(>|>>|tee |cp |install |cat >|cat >>)' >"$TMPDIR_V/neg-pam-write.out" 2>/dev/null; then
	ok "negative: build-hook write into /etc/pam.d is detected"
else
	# looser: any active /etc/pam.d path is already forbidden in real snippet policy
	if grep -vE '^\s*#' "$NEG/buildhook/bad-build.sh.snippet" | grep -qE '/etc/pam\.d'; then
		ok "negative: active /etc/pam.d path in build hook is detected"
	else
		fail "negative: pam.d write fixture not detected"
	fi
fi

# N5: real build snippets audit — no active /etc/pam.d writes (documentable endpoint residual)
snippet_pam_write=0
for snip in planning/integration/d-duress/build.sh.snippet \
	planning/integration/d-duress/Containerfile.snippet; do
	[[ -f "$snip" ]] || continue
	if grep -vE '^\s*#|^\s*$' "$snip" | grep -nE '/etc/pam\.d' >"$TMPDIR_V/snip-pam.out" 2>/dev/null; then
		fail "active /etc/pam.d reference in $snip (build hooks must not touch PAM)"
		cat "$TMPDIR_V/snip-pam.out" >&2 || true
		snippet_pam_write=1
	fi
done
if [[ "$snippet_pam_write" -eq 0 ]]; then
	ok "audit: build/Containerfile snippets have no active /etc/pam.d paths"
fi

# N6: live build.sh (post-merge) must not install pam.d snippets under /etc/pam.d
if [[ -f build_files/build.sh ]]; then
	if grep -vE '^\s*#|^\s*$' build_files/build.sh | grep -nE '/etc/pam\.d' >/dev/null 2>&1; then
		fail "build_files/build.sh has active /etc/pam.d reference"
	else
		ok "audit: build_files/build.sh has no active /etc/pam.d paths"
	fi
	if grep -vE '^\s*#|^\s*$' build_files/build.sh | grep -E '/usr/share/hyprwave/duress/pam\.d' >/dev/null; then
		ok "audit: build.sh deploys reference pam.d under /usr/share only"
	else
		fail "audit: build.sh missing share-only pam.d deploy path"
	fi
	if grep -qiE 'OFF BY DEFAULT|no PAM enable' build_files/build.sh; then
		ok "audit: build.sh documents duress OFF BY DEFAULT"
	else
		fail "audit: build.sh missing OFF BY DEFAULT language for duress"
	fi
else
	ok "audit: build_files/build.sh not present (snippet-only tree)"
fi

# N7: docs/layout language matches stock image paths
for doc in build_files/duress/ENABLE.md build_files/duress/README.md; do
	if grep -qE '/usr/share/hyprwave/duress' "$doc" && grep -qE '/etc/duress\.d' "$doc"; then
		ok "layout paths present in $doc"
	else
		fail "layout paths missing in $doc"
	fi
done
if grep -qiE 'Zero|zero|no pam_duress|/etc/pam\.d' build_files/duress/ENABLE.md &&
	grep -qiE 'OFF|Default: OFF|stock' build_files/duress/ENABLE.md; then
	ok "ENABLE.md documents stock PAM-inert residual"
else
	fail "ENABLE.md missing stock PAM-inert residual language"
fi
if grep -qiE 'still OFF|Still OFF|OFF by default' planning/integration/d-duress/RESIDUALS.md; then
	ok "RESIDUALS.md has still-OFF residual"
else
	fail "RESIDUALS.md missing still-OFF residual"
fi

# setup --help / dry-run operator-only + PAM off language
if bash build_files/duress/hyprwave-duress-setup --help 2>&1 | grep -qiE 'OFF BY DEFAULT|operator'; then
	ok "setup --help states operator-only / PAM OFF BY DEFAULT"
else
	fail "setup --help missing operator-only / OFF BY DEFAULT language"
fi
if bash build_files/duress/hyprwave-duress-setup --dry-run --mild-template >/tmp/duress-dry3.out 2>/tmp/duress-dry3.err; then
	if grep -qiE 'PAM stays OFF|never edits /etc/pam\.d|operator preview' /tmp/duress-dry3.err; then
		ok "setup --dry-run banner states PAM stays OFF"
	else
		fail "setup --dry-run missing PAM-off banner"
		cat /tmp/duress-dry3.err >&2 || true
	fi
else
	fail "setup --dry-run --mild-template failed after banner change"
fi

# cleanup negative fixtures early (also covered by EXIT trap)
rm -rf "$NEG"
ok "negative fixtures cleaned up"

echo
if [[ "$FAILED" -ne 0 ]]; then
	echo "RESULT: FAILED"
	exit 1
fi
echo "RESULT: PASSED"
exit 0
