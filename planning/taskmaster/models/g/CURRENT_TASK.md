# CURRENT_TASK

status: OPEN  
task_id: G-W1-005  
wave: 1  
issued: 2026-08-07T05:25:00Z  
title: Program closeout matrix — ENDPOINT verification after merge  

## Objective

Produce a Director-facing closeout matrix: each ENDPOINT product item → exact verification command/evidence after serial merge, so program can reach `PROGRAM_COMPLETE` without guesswork. Still **do not merge** lanes.

## Exclusive paths

- `planning/qa/**`
- `planning/integration/g-qa/**`
- `planning/taskmaster/models/g/**`

## Forbidden

- Merging product lanes
- Editing A–F exclusive product paths

## Requirements

- [ ] `planning/integration/g-qa/PROGRAM-CLOSEOUT.md` — table ENDPOINT §Product 1–10 → status (open/lane/main) → verify command → owner lane
- [ ] Link INTEGRATION-DAY, ENDPOINT-RESIDUALS, SMOKE-MATRIX §9
- [ ] Note pre-merge baseline: pins fail on main until A; C/D need snippets
- [ ] ≥2 commits; push `lane/g-qa`

## Deliverables

- PROGRAM-CLOSEOUT.md

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
