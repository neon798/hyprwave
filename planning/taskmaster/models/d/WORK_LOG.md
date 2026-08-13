# Model D Work Log

(append only)

## 2026-08-07 — D-W1-001

- Implemented security review pack on `lane/d-duress` (worktree).
- Added `build_files/duress/THREAT-MODEL.md` (assets, adversaries, residual risks, LUKS/forensics non-goals).
- Added mild template `templates/20-local-only-clear.sh` (`~/.cache` only) + README severity row + `--local-clear-template`.
- Extended `hyprwave-duress-setup` to v1.2.0 with read-only `--verify` (modes + matching `.sha256`).
- `build-duress.sh`: echo pin + UTC date; BUMP-style `PAM_DURESS_COMMIT` override docs.
- `ENABLE.md` (packaging + integration): lockout recovery + bootc PAM drift commands.
- `planning/integration/d-duress/DRILL.md` 30–45 min disposable VM procedure.
- Expanded `validate.sh` (THREAT-MODEL, no `*.sha256`, no default required pam_duress, `--verify` fixtures).
- Commits: e7ccce3, a348bb4, 16535c9 (+ DONE meta).
- `bash planning/integration/d-duress/validate.sh` → PASSED.

## 2026-08-07 — D-W1-002

- Negative-path validate, operator FAQ, packaging dry-run proof on `lane/d-duress`.
- Added `planning/integration/d-duress/FAQ.md` (13 Q&As: scope, off-by-default, signing, greeter/hyprlock, lockout, bootc, residual vs LUKS, templates, validate, no CI enable).
- Added `planning/integration/d-duress/OPERATOR-RUNBOOK.md` (ordered enable → VM test → disable/rollback; links DRILL.md).
- Expanded `validate.sh`: required FAQ/runbook paths; content guards; **negative fixtures** in temp dirs (planted `*.sha256`, `auth required pam_duress`, missing THREAT-MODEL, build-hook pam.d write); cleanup via trap + early rm.
- **Snippet PAM audit (no build-hook writes to `/etc/pam.d`):**
  - `build.sh.snippet`: only installs under `/usr/share/hyprwave/duress`, `/usr/bin`, empty `/etc/duress.d`; `/etc/pam.d/*` appear only in trailing comments (“Explicitly do NOT touch”).
  - `Containerfile.snippet`: stages binaries via DESTROOT; comments forbid sed/cp into `/etc/pam.d/*`.
  - `build_files/duress/pam.d/*.snippet`: documentation/reference only (not installed as live stacks).
  - validate re-asserts no active (non-comment) `/etc/pam.d` paths in build/Containerfile snippets.
- Confirmed `build-duress.sh` still echoes `pin=` + full 40-char `PAM_DURESS_COMMIT` and `date=` UTC; dry-run setup still green in validate.
- No new mild template/flag needed (existing severity table accurate).
- Commits: 7de27a9, f758537, 7d35112 (+ DONE meta).
- `bash planning/integration/d-duress/validate.sh` → PASSED.

## 2026-08-07 — D-W1-003

- Signing workflow docs + snippet self-test + residual operator duties on `lane/d-duress`.
- Added `planning/integration/d-duress/SIGNING.md` (dry-run, setup sign, `--verify` success, disposable `$TMPDIR` lab with `duress_sign`, never commit `*.sha256`).
- Added `planning/integration/d-duress/RESIDUALS.md` (LUKS, physical/root, signed-script trust root, bootc PAM drift, incomplete wipe, social/ops, integration boundary).
- Added `planning/integration/d-duress/snippet-selftest.sh` (build + Containerfile snippets: no active pam.d writes, no pam_duress enable, no `*.sha256`).
- `validate.sh` invokes snippet-selftest; gates SIGNING/RESIDUALS content; README severity + FAQ/runbook/SIGNING links.
- Packaging + integration READMEs: severity tables for all three templates; doc index polish.
- Commits: 2733afe, 8f8d2cc, 240b4e5 (+ DONE meta).
- `bash planning/integration/d-duress/validate.sh` → PASSED; `snippet-selftest.sh` → PASSED.

## 2026-08-07 — D-W1-004

- Pre-merge duress packaging freeze on `lane/d-duress`.
- Added `planning/integration/d-duress/INTEGRATOR-CHECKLIST.md` (merge tree → snippets → **do not enable PAM** → validate → operator ENABLE docs only).
- Integration + packaging READMEs index SIGNING, RESIDUALS, FAQ, OPERATOR-RUNBOOK, DRILL, INTEGRATOR-CHECKLIST.
- `validate.sh` gates checklist content + full README doc index.
- Freeze reaffirm: zero `*.sha256`; snippet-selftest PAM-inert; no accidental enable path.
- Commits: 99dad80, f67ffb9, f88bb3d (+ DONE meta).
- `snippet-selftest.sh` + `validate.sh` → PASSED.

## 2026-08-07 — D-W1-005

- Integration-day one-page gate card on `lane/d-duress`.
- Added `planning/integration/d-duress/INTEGRATION-DAY.md` (merge D → snippets → snippet-selftest + validate → no PAM; links INTEGRATOR-CHECKLIST + SIGNING do-not-commit).
- README indexes INTEGRATION-DAY; validate gates presence/content.
- Commits: c8ea0ae (+ DONE meta).
- `snippet-selftest.sh` + `validate.sh` → PASSED.

## 2026-08-07 — D-W1-006 (integration standby heartbeat)

- Wave 1 product scope for Model D **frozen**; standby for human/Director serial merge
  (`planning/integration/g-qa/INTEGRATION-DAY.md`). No new product work invented.
- Freeze tip SHA: `adbb4f4` (`adbb4f4b4c01a63f9b4fc31464ce99628b0261f8`) — tip of `lane/d-duress`
  after D-W1-005 DONE meta.
- Optional self-check (re-run): `bash planning/integration/d-duress/validate.sh` → **PASSED**;
  `snippet-selftest.sh` → **PASSED**; zero `*.sha256` under packaging paths.
- Status: **standby for integration** — await merge of D packaging (assets only; PAM OFF).

## 2026-08-07 — D-W1-HOLD (refresh heartbeat)

- Director reissued HOLD (`reissued: 2026-08-07T06:05:00Z`); refreshed `planning/taskmaster/models/d/` from `origin/main`.
- Product freeze unchanged: tip `adbb4f4` (PAM OFF, assets only). Lane HEAD post-heartbeat will track HOLD meta only.
- **status remains OPEN** — will not mark HOLD as DONE; no product scope; awaiting serial merge via `planning/integration/g-qa/INTEGRATION-DAY.md`.

## 2026-08-07T12:20Z — D-W1-HOLD poll heartbeat

- Fetched `origin/main`; refreshed `planning/taskmaster/models/d/` (still HOLD OPEN; director tip `3db77d4`, no `task_id` change).
- No product work; did not mark DONE.
- Freeze tip unchanged: `adbb4f4`.
- Idle until Director changes `task_id`.

## 2026-08-13 — D-W2-001

- Image-backed duress safety pass on `lane/d-duress` after merge of origin/main.
- **Image inspect** (`localhost/hyprwave:latest`, 2026-08-13):
  - `/usr/lib64/security/pam_duress.so` present (20816 bytes)
  - `/usr/bin/hyprwave-duress-setup` present
  - `grep -R pam_duress /etc/pam.d` → **ZERO lines**
  - No `*.sha256` under `/usr/share/hyprwave/duress` or `/etc/duress.d`
  - Layout: `/usr/share/hyprwave/duress/{README,ENABLE,pam.d,templates,BUILD-INFO}`; `/etc/duress.d/README` only
- Tightened `snippet-selftest.sh`: share-only pam.d deploy; read-only audit of live `build_files/build.sh` (no `/etc/pam.d` writes).
- Expanded `validate.sh` N6/N7: build.sh PAM-inert, layout docs, RESIDUALS still-OFF, setup --help/--dry-run PAM-off language.
- `build.sh.snippet`: install THREAT-MODEL when present; pam.d docs only under `/usr/share/.../pam.d`; template list includes 20-local-only.
- ENABLE/README path tables match stock image; RESIDUALS “Still OFF — image residual”.
- `hyprwave-duress-setup` v1.2.1: operator-only help + dry-run banner (never edits PAM).
- `bash planning/integration/d-duress/validate.sh` → PASSED
- `bash planning/qa/run-all.sh --only duress-safety` → RESULT OK
- No default PAM enable; no `*.sha256` added.

## 2026-08-13 — D-W2-002 (operator drill vs image paths; still OFF)

- Merged origin/main; accepted D-W2-002 (HOLD cancelled; 2m poll).
- Rewrote `planning/integration/d-duress/DRILL.md`:
  - Banner: rehearsal only; production enable stays ENABLE.md / runbook §3+
  - Stock image path table: `/usr/bin/hyprwave-duress-setup` (not sbin),
    `/usr/share/hyprwave/duress`, `/etc/duress.d` README-only,
    `/usr/lib64/security/pam_duress.so`, zero `/etc/pam.d` pam_duress
  - Phases A–C: validate + path inventory + --help/--status/--verify/--dry-run
  - Optional Phase D mild sign still PAM OFF; STOP before any PAM edit
- OPERATOR-RUNBOOK: drill vs enable split; real path checks in §0–§1
- validate.sh: gate DRILL image paths + rehearsal scope + no enable recipe in phases
- RESIDUALS.md still OFF residual unchanged
- `bash planning/integration/d-duress/validate.sh` → PASSED
- `bash planning/qa/run-all.sh --only duress-safety` → RESULT OK
- Commits: c897ee1, 5bc50c1, c904dd1, 411c9c6, 7663596 (+ DONE meta)

## 2026-08-13 — D-W3-001 (pam snippets must not install to /etc/pam.d)

- Merged origin/main; accepted D-W3-001.
- `validate.sh`: `active_pam_snippet_to_etc` helper + N7 negative fixtures
  (cp pam.d → /etc/pam.d, install snippet over system-auth, share-only OK).
- Real-tree audit: `build.sh.snippet` + read-only `build_files/build.sh` must pass.
- `snippet-selftest.sh`: same helper + temp negative fixtures.
- Did **not** edit production `build.sh` (A owns pins); no PAM enable; no `*.sha256`.
- RESIDUALS still OFF.
- `bash planning/integration/d-duress/validate.sh` → PASSED
- `bash planning/qa/run-all.sh --only duress-safety` → RESULT OK
- Commits: 8924251, 045536f, + this series (+ DONE meta); tip ef5c41e

## 2026-08-13 — D-W4-001 (merge-prep checklist + validate green)

- Merged origin/main; accepted D-W4-001.
- Refreshed `INTEGRATOR-CHECKLIST.md` for W2–W4: never default-on, DRILL
  PAM-inert paths, N7 pam-snippet→/etc/pam.d, duress-safety, stock image paths.
- validate gates checklist merge-prep markers; integration README wave index.
- RESIDUALS still OFF; no PAM enable; no `*.sha256`; no live build.sh edit.
- `bash planning/integration/d-duress/validate.sh` → PASSED
- `bash planning/qa/run-all.sh --only duress-safety` → RESULT OK
- Commits: 2973b5c, 73334ad, + this series; tip 1fc067d

## 2026-08-13 — D-W5-001 (post-merge validate; Waves 2–4 on main)

- Merged `origin/main` into `lane/d-duress` (already up to date on re-poll).
- Re-ran post-merge safety only; no product/PAM changes; no `*.sha256`.
- `bash planning/integration/d-duress/validate.sh` → **PASSED**
- `bash planning/qa/run-all.sh --only duress-safety` → **RESULT: OK** (9 PASS)
- PAM still OFF BY DEFAULT (snippet-selftest + build.sh audit green).
- Criteria: validate PASS, duress-safety PASS, push `lane/d-duress`.
