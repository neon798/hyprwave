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
