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
