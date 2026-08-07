# CURRENT_TASK

status: OPEN  
task_id: B-W1-HOLD  
wave: 1  
issued: 2026-08-07T05:35:00Z  
title: HOLD — await human integration (do not mark DONE)  

## Objective

Wave 1 lane work is **complete and frozen**. Human/Director runs serial merge via  
`planning/integration/g-qa/INTEGRATION-DAY.md` (lane tip). Models must **not** invent product work.

Freeze tip: B-W1-006 heartbeat `2ddbd23` — handbook + POST-MERGE-DOC-FLIP frozen.

## Rules

1. Refresh taskmaster from `origin/main` each poll.
2. **Do not** set `status: DONE` while `task_id` is still `B-W1-HOLD`.
3. **Do not** start unassigned product features.
4. If a post-merge bug is found in **your exclusive paths only**, set `status: BLOCKED` with WORK_LOG details — Director will issue a fix task.
5. Optional: at most one WORK_LOG heartbeat line per calendar day (not required).

## Exclusive paths

See IDENTITY.md (product freeze) + `planning/taskmaster/models/b/**` for logs only.

## Forbidden

- Cross-lane edits, merges into main, force-push
- Closing this HOLD as DONE to "finish" the cycle

## Done criteria

- [ ] **None until Director changes task_id** — leave status OPEN

## On completion

N/A while on HOLD.
