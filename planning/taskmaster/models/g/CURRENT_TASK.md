# CURRENT_TASK

status: OPEN  
task_id: G-W1-002  
wave: 1  
issued: 2026-08-07T04:45:00Z  
title: Multi-lane fetch checks, endpoint residual tracker, CI harness snippet  

## Objective

Deepen QA toward ENDPOINT: optional multi-ref checks against remote lanes, residual tracker for program closeout, and a CI-ready harness snippet — still **no** merging product lanes.

## Exclusive paths

- `planning/qa/**`
- `planning/integration/g-qa/**`
- `planning/taskmaster/models/g/**`
- Optional additive Justfile fragment under `planning/qa/` only (not root Justfile unless purely additive and risk-free)

## Forbidden

- Implementing Assistant/Duress/desktop features
- Force-merging other lanes
- Editing exclusive product paths of A–F

## Requirements

- [ ] `planning/qa/check-lane-artifacts.sh` — given `git` available, can `git ls-tree`/`git show` **optional** `ORIGIN_LANE_*` refs or default `origin/lane/*` to verify expected paths exist (soft-WARN if refs missing; FAIL only when ref present but artifact missing)
- [ ] `planning/integration/g-qa/ENDPOINT-RESIDUALS.md` — checklist mapped from `ENDPOINT.md` product items 1–10 with status (met on main / met on lane / open) based on read-only inspection
- [ ] Expand MERGE-PLAYBOOK with pre-merge `run-all.sh` gates and post-merge expected flips (pins FAIL→PASS after A, etc.)
- [ ] `planning/qa/ci-snippet.yml` or markdown embedding for a GH workflow job (A may copy later) — no secrets
- [ ] `run-all.sh` includes new check (or documents why separate); summary table still clear
- [ ] Theme exceptions list remains accurate
- [ ] ≥3 commits; push `lane/g-qa`
- [ ] `bash planning/qa/run-all.sh` runs; document exit semantics

## Deliverables

- Lane artifact checker, endpoint residuals tracker, CI snippet, playbook updates

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
