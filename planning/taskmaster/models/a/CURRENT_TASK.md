# CURRENT_TASK

status: OPEN  
task_id: A-W1-004  
wave: 1  
issued: 2026-08-07T05:15:00Z  
title: Integration-day pin gate card + post-merge verify sheet  

## Objective

Ship a one-page **integration-day** card for Model A so the human integrator can merge A first and prove pins/CI green without rereading all of MERGE-READY.

## Exclusive paths

- `build_files/versions.env`
- `build_files/build.sh` (pin/checksum only)
- `.github/workflows/*`
- `planning/integration/a-stabilize/**`
- `planning/taskmaster/models/a/**`

## Forbidden

- Wiring Assistant/Duress into build.sh
- Other models’ paths
- Enabling duress PAM

## Requirements

- [ ] `planning/integration/a-stabilize/INTEGRATION-DAY.md` — ordered: fetch, merge A, conflict tips, post-merge commands (`verify-pins --head`, `--checksum --light`, floating-token grep, optional ghcr-pull-test)
- [ ] Link MERGE-READY, CI-MATRIX, COSIGN, BUMP
- [ ] Confirm no floating `/releases/latest` still on branch
- [ ] ≥2 commits; push `lane/a-stabilize`

## Deliverables

- INTEGRATION-DAY.md (+ tiny doc cross-links)

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
