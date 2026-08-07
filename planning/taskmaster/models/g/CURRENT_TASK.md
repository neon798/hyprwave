# CURRENT_TASK

status: OPEN  
task_id: G-W1-003  
wave: 1  
issued: 2026-08-07T04:55:00Z  
title: Pre-integration dry-run report + conflict hotspot probe  

## Objective

Produce an actionable **pre-merge dry-run** for the integrator: simulate merge order A→G with conflict probes, refresh endpoint residuals after W1-002/003 lane tips, and document go/no-go gates — still **do not merge** product lanes.

## Exclusive paths

- `planning/qa/**`
- `planning/integration/g-qa/**`
- `planning/taskmaster/models/g/**`

## Forbidden

- Force-merging other lanes into main
- Editing exclusive product paths of A–F
- Enabling features in build.sh

## Requirements

- [ ] `planning/integration/g-qa/PRE-MERGE-DRY-RUN.md` — for each lane tip SHA, list unique paths vs `origin/main`, predicted conflict files (esp. `build.sh`, README, workflows, skel)
- [ ] Optional script `planning/qa/probe-merge-conflicts.sh` that uses `git merge-tree` (or equivalent) against `origin/main` for each `origin/lane/*` **read-only**; prints conflict paths; exit 0 even if conflicts found (report mode) unless `--fail-on-conflict`
- [ ] Refresh `ENDPOINT-RESIDUALS.md` against current `origin/main` + latest lane tips
- [ ] Expand SMOKE-MATRIX with “minimum green before GHCR publish” gate list
- [ ] `run-all.sh` still works; document any new check
- [ ] ≥3 commits; push `lane/g-qa`

## Deliverables

- PRE-MERGE-DRY-RUN.md (+ optional probe script), updated residuals/smoke

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
