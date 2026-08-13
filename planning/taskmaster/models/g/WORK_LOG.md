# Model G Work Log

(append only)

## G-W1-001 — 2026-08-07

**Status:** DONE  
**Branch:** `lane/g-qa` (worktree `/home/zen/hyprwave-g-qa`)  
**Task:** QA harness + merge playbook for seven-lane integration

### Work performed

1. Created `planning/qa/` harness:
   - `lib/common.sh` — PASS/FAIL/WARN/SKIP helpers + summary table
   - `check-pins-static.sh` — fails on `/releases/latest` in `build.sh`; WARNs if `versions.env` missing; validates keys/sha shape when present
   - `check-themes.sh` — 11 themes scanned for looknfeel, waybar/walker CSS, ghostty, wallpapers; optional `theme-exceptions.list`
   - `check-no-wofi-swaybg.sh` — live-file scan (handles broken skel absolute symlinks); positive walker/hyprpaper signals
   - `check-duress-safety.sh` — soft-WARN if D not merged; no `*.sha256` + `validate.sh` when present
   - `check-assistant.sh` — soft-WARN if C not merged; `go test ./...` when present
   - `run-all.sh` — ordered orchestrator, `--only`, harness summary, exit 1 on any FAIL
   - `README.md` — usage, soft-skip policy, CI suggestions

2. Created `planning/integration/g-qa/`:
   - `MERGE-PLAYBOOK.md` — order A→B→C→D→E→F→G, hotspots, C/D snippet apply, QA gates, rollback
   - `SMOKE-MATRIX.md` — build + greeter + Hyprland/COSMIC (links E/F SESSION-SMOKE with fallbacks) + cross-cutting

### Host run (on unpinned main baseline)

- `pins-static`: **FAIL** (expected — 6× `/releases/latest` until A merges)
- `themes`: PASS (11 themes)
- `no-wofi-swaybg`: PASS
- `duress-safety` / `assistant`: WARN soft-skip (lanes not on this tree)
- Full harness exit 1 solely due to unpinned `build.sh` (correct fail-closed)

### Notes for Director

- Re-run `bash planning/qa/run-all.sh` after merging A/C/D; WARNs should flip to PASS.
- G does not merge other lanes; playbook is human/Director-driven.

## G-W1-002 — 2026-08-07

**Status:** DONE  
**Branch:** `lane/g-qa` (worktree `/home/zen/hyprwave-g-qa`)  
**Task:** Multi-lane fetch checks, endpoint residual tracker, CI harness snippet

### Work performed

1. `planning/qa/check-lane-artifacts.sh` — multi-ref checks for lanes A–G via `git rev-parse` + `git cat-file`; env overrides `ORIGIN_LANE_A..G`; `LANE_ARTIFACTS_OFF=1` skip; WARN missing refs, FAIL missing paths on present refs.
2. Wired into `run-all.sh` as `lane-artifacts` (ordered last); help/exit semantics documented (0/1/2).
3. `planning/integration/g-qa/ENDPOINT-RESIDUALS.md` — ENDPOINT product items 1–10 with met-on-main / met-on-lane / open / partial from inspection of `origin/main` + `origin/lane/*`.
4. MERGE-PLAYBOOK §6 expanded: pre-merge baseline, expected FAIL/WARN→PASS flips, post-merge closeout.
5. `planning/qa/ci-snippet.yml` — static / full / advisory jobs, no secrets; README updated.
6. Theme exceptions list unchanged (empty, accurate for all 11 themes PASS).

### Host run

- Full harness: **FAIL** solely from `pins-static` (6× `/releases/latest` on unpinned main baseline) — expected until A merges.
- `themes` / `no-wofi-swaybg` PASS; `duress-safety` / `assistant` WARN soft-skip; `lane-artifacts` PASS (7 refs, 25 paths).
- `LANE_ARTIFACTS_OFF=1` → SKIP, harness OK.

### Commits

- `cb7d348` qa: multi-ref lane-artifacts + run-all
- `b51b10e` integration: ENDPOINT-RESIDUALS + playbook flips
- `e993e8f` qa: ci-snippet.yml + README exit docs
- (this) taskmaster DONE record

### Notes for Director

- After A merge, re-run: pins FAIL→PASS.
- CI: copy `planning/qa/ci-snippet.yml` into workflows when ready.
- Refresh ENDPOINT-RESIDUALS after each serial merge; G still does not merge lanes.

## G-W1-003 — 2026-08-07

**Status:** DONE  
**Branch:** `lane/g-qa`  
**Task:** Pre-integration dry-run + conflict hotspot probe

### Work performed

1. `planning/qa/probe-merge-conflicts.sh` — read-only `git merge-tree --write-tree` per lane; report mode exit 0; `--product-only` / `--fail-on-conflict` / `--lanes`.
2. `planning/integration/g-qa/PRE-MERGE-DRY-RUN.md` — tips, inventories, go/no-go: **product merges clean** vs main; taskmaster conflicts expected; C/D snippets remain post-merge work.
3. Refreshed `ENDPOINT-RESIDUALS.md` for main `2eed66f` + current lane tips.
4. SMOKE-MATRIX **§9** minimum green before GHCR publish (hard P1–P7 + soft S1–S5).
5. README: probe not in `run-all` (integration-time advisory).

### Probe result (product-only)

All seven lanes **PASS** (taskmaster-only noise filtered).  
Harness still **FAIL** only on `pins-static` until A merges (expected).

### Commits

- probe script + README
- PRE-MERGE-DRY-RUN.md
- ENDPOINT-RESIDUALS + SMOKE-MATRIX §9
- taskmaster DONE record

## Poll — 2026-08-07 (post G-W1-003)

**Status:** idle / reaffirm DONE  
**Note:** `origin/main` still listed G-W1-003 as OPEN (director task file lag). Lane deliverables already shipped; re-ran `probe-merge-conflicts.sh --product-only` vs main `371ea34` — all seven lanes **product-clean**. Refreshed tip SHAs in PRE-MERGE-DRY-RUN + ENDPOINT-RESIDUALS (A `3022cfc`, B `6be80a8`, E `b9a218f`, …). No new product work.

## G-W1-004 — 2026-08-07

**Status:** DONE  
**Branch:** `lane/g-qa`  
**Task:** Integration-day master runbook for human integrator

### Work performed

1. `planning/integration/g-qa/INTEGRATION-DAY.md` — half-day schedule T0–T8; non-negotiables; conflict policy (product vs taskmaster); per-lane merge + gates; C/D snippet steps; GHCR go/no-go (SMOKE §9); abort/rollback; log template; cross-links to A MERGE-READY, B POST-MERGE, C HANDOFF, D/F INTEGRATOR-CHECKLIST, E INTEGRATION-DAY.
2. Refreshed ENDPOINT-RESIDUALS + PRE-MERGE-DRY-RUN tips vs main `6c5da71` / current lanes; re-probe product-clean.
3. Cross-linked MERGE-PLAYBOOK, SMOKE-MATRIX, QA README.

### Commits

- INTEGRATION-DAY.md
- residuals + dry-run tips
- cross-links
- taskmaster DONE

## G-W1-005 — 2026-08-07

**Status:** DONE  
**Branch:** `lane/g-qa`  
**Task:** Program closeout matrix — ENDPOINT verification after merge

### Work performed

1. `planning/integration/g-qa/PROGRAM-CLOSEOUT.md` — ENDPOINT §Product 1–10 matrix: pre-merge status, owner, verify commands, block flags; process section; one-shot host script; Director decision rule.
2. Pre-merge baseline documented: pins FAIL (6× latest), no harness/docs/assistant/duress on main; C/D snippets required.
3. Cross-links from INTEGRATION-DAY, ENDPOINT-RESIDUALS, SMOKE-MATRIX; residual tip SHAs refreshed (main `98fe075`).

### Notes

- G did not merge lanes or set PROGRAM_COMPLETE.

## Poll heartbeat — 2026-08-07 (G-W1-HOLD)

**Status:** OPEN HOLD — idle  
Wave 1 frozen at G-W1-005. Awaiting human integration via INTEGRATION-DAY.md. No product work; no DONE on HOLD.

## G-W2-001 — 2026-08-13

**Status:** DONE  
**Branch:** `lane/g-qa` (worktree `/home/zen/hyprwave-g-qa`, rebased onto `origin/main`)  
**Task:** Container image smoke check + T8 residual update

### Work performed

1. `planning/qa/check-image.sh` — skip-if-missing podman inspect:
   - `HYPRWAVE_IMAGE` (default `localhost/hyprwave:latest`): assistant version, hyprwave-theme, walker, hyprpaper, ≥11 themes, catalog.toml, ENABLE.md, no pam_duress, sddm enabled, no wofi/swaybg
   - Optional cosmic (`HYPRWAVE_COSMIC_IMAGE` / `--cosmic`): cosmic-greeter, no cosmic-store, flatarcade, hyprwave-theme
2. Registered `image` in `run-all.sh` after `assistant`; README + help docs for `--only image`
3. Refreshed ENDPOINT-RESIDUALS / PROGRAM-CLOSEOUT / SMOKE-MATRIX §9.0:
   - CI run `31662742064` both variants PASS
   - Local hyprland + cosmic image inspect PASS
   - GHCR anonymous still 403; VM smoke still open
   - Residuals no longer claim “all T8 pending”

### Host run

- `bash planning/qa/run-all.sh` → **RESULT OK** (image PASS 18/0 on local tags)
- `bash planning/qa/run-all.sh --only image` → PASS

### Notes for Director

- Lane tip reset onto post-merge `origin/main` (HOLD heartbeats discarded; product already on main).
- PROGRAM_COMPLETE still open until VM + GHCR policy.

## G-W2-003 — 2026-08-13

**Status:** DONE  
**Branch:** `lane/g-qa`  
**Task:** Wire check-image into CI snippet as continue-on-error / skip-ok

### Work performed

1. `planning/qa/ci-snippet.yml` — new job `packaging-qa-image`:
   - `continue-on-error: true` (advisory; never blocks)
   - `bash planning/qa/run-all.sh --only image`
   - env `HYPRWAVE_IMAGE` / `HYPRWAVE_COSMIC_IMAGE`; no secrets / no GHCR pull
   - Comments: GH-hosted typically SKIP; enable on self-hosted after build
2. README: section “Advisory image job (self-hosted / image-bearing runners)”
3. SMOKE-MATRIX §9.0 + ENDPOINT-RESIDUALS: snippet advisory-only; live workflows remain A
4. No `.github/workflows/*` edits

### Host run

- `bash planning/qa/run-all.sh` → **RESULT OK**

## G-W3-001 — 2026-08-13

**Status:** DONE  
**Branch:** `lane/g-qa`  
**Task:** check-image.sh --cosmic PASS; residuals VM-only

### Work performed

1. Ran `bash planning/qa/check-image.sh --cosmic` against `localhost/hyprwave-cosmic:latest` → **PASS** (18 PASS / 0 FAIL).
2. Narrowed ENDPOINT-RESIDUALS / PROGRAM-CLOSEOUT / SMOKE-MATRIX §9.0: image builds **met**; remaining open = **VM qcow2 smokes + GHCR anon 403** only. Did **not** claim VM smoke done.
3. `bash planning/qa/run-all.sh` → RESULT OK.

### check-image.sh --cosmic snippet

```
  HYPRWAVE_IMAGE=localhost/hyprwave:latest
  HYPRWAVE_COSMIC_IMAGE=localhost/hyprwave-cosmic:latest
PASS image.podman: podman available
PASS image.hyprland.present: found localhost/hyprwave:latest
PASS image.hyprland.assistant: hyprwave-assistant hyprwave-assistant 0.2.2
PASS image.hyprland.bin.hyprwave-theme: hyprwave-theme present
PASS image.hyprland.bin.walker: walker present
PASS image.hyprland.bin.hyprpaper: hyprpaper present
PASS image.hyprland.themes: themes count 11 (≥11)
PASS image.hyprland.catalog: catalog.toml present
PASS image.hyprland.enable_md: ENABLE.md present
PASS image.hyprland.pam: no pam_duress in /etc/pam.d
PASS image.hyprland.sddm: sddm enabled (ok)
PASS image.hyprland.no-legacy: no wofi/swaybg binaries
PASS image.cosmic.present: found localhost/hyprwave-cosmic:latest
PASS image.cosmic.greeter: cosmic-greeter present
PASS image.cosmic.greeter-enabled: cosmic-greeter enabled (ok:enabled)
PASS image.cosmic.no-store: cosmic-store not installed
PASS image.cosmic.flatarcade: flatarcade present
PASS image.cosmic.theme-tool: hyprwave-theme present
=== check-image ===
PASS    image.podman                  podman available
PASS    image.hyprland.present        found localhost/hyprwave:latest
PASS    image.hyprland.assistant      hyprwave-assistant hyprwave-assistant 0.2.2
PASS    image.hyprland.bin.hyprwave-theme  hyprwave-theme present
PASS    image.hyprland.bin.walker     walker present
PASS    image.hyprland.bin.hyprpaper  hyprpaper present
PASS    image.hyprland.themes         themes count 11 (≥11)
PASS    image.hyprland.catalog        catalog.toml present
PASS    image.hyprland.enable_md      ENABLE.md present
PASS    image.hyprland.pam            no pam_duress in /etc/pam.d
PASS    image.hyprland.sddm           sddm enabled (ok)
PASS    image.hyprland.no-legacy      no wofi/swaybg binaries
PASS    image.cosmic.present          found localhost/hyprwave-cosmic:latest
PASS    image.cosmic.greeter          cosmic-greeter present
PASS    image.cosmic.greeter-enabled  cosmic-greeter enabled (ok:enabled)
PASS    image.cosmic.no-store         cosmic-store not installed
PASS    image.cosmic.flatarcade       flatarcade present
PASS    image.cosmic.theme-tool       hyprwave-theme present
Totals: PASS=18 FAIL=0 WARN=0 SKIP=0
```

### Notes

- No product/workflow edits. Local image build no longer tracked as pending.
