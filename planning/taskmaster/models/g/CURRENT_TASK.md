# CURRENT_TASK

status: OPEN  
task_id: G-W1-004  
wave: 1  
issued: 2026-08-07T05:15:00Z  
title: Integration-day master runbook for human integrator  

## Objective

Single **INTEGRATION-DAY.md** the human/Director follows: serial A→G merges, probe after each step, run-all expectations, snippet apply for C/D, go/no-go for GHCR publish — still **do not merge** yourself unless task explicitly says (it does not).

## Exclusive paths

- `planning/qa/**`
- `planning/integration/g-qa/**`
- `planning/taskmaster/models/g/**`

## Forbidden

- Merging product lanes into main
- Editing A–F product exclusive paths

## Requirements

- [ ] `planning/integration/g-qa/INTEGRATION-DAY.md` — time-boxed procedure: fetch, merge order, conflict policy (taskmaster vs product), after-each-lane `run-all` / probe commands, C/D snippet apply, smoke matrix P1 gates, abort criteria
- [ ] Refresh ENDPOINT-RESIDUALS.md tip SHAs once more
- [ ] Cross-link MERGE-PLAYBOOK, PRE-MERGE-DRY-RUN, SMOKE-MATRIX §9, each lane INTEGRATION-DAY if present
- [ ] ≥3 commits; push `lane/g-qa`

## Deliverables

- INTEGRATION-DAY.md + residuals refresh

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
