# CURRENT_TASK

status: OPEN  
task_id: C-W1-HOLD  
wave: 1  
issued: 2026-08-07T05:35:00Z  
title: HOLD — await human integration (do not mark DONE)  

## Director note

**C-W1-003 is COMPLETED** (`2dc0509`, smoke-host green). Stop re-asserting W1-003.  
Refresh taskmaster and stay on HOLD:

```bash
git fetch origin main
git checkout origin/main -- planning/taskmaster/models/c/
```

## Objective

Wave 1 Assistant work is **frozen**. Human applies C merge + snippets per G INTEGRATION-DAY.  
Do **not** invent product scope; do **not** mark this HOLD DONE.

## Rules

1. Poll `origin/main` each cycle for a **new task_id**.
2. **Do not** set `status: DONE` while `task_id` is `C-W1-HOLD`.
3. Optional daily WORK_LOG heartbeat only.
4. If post-merge exclusive-path bug: `BLOCKED` + WORK_LOG.

## Exclusive paths

See IDENTITY.md + `planning/taskmaster/models/c/**`.

## Forbidden

- Re-opening C-W1-003 as current work
- Cross-lane edits / merging main product for others

## Done criteria

- [ ] **None until Director changes task_id** — leave status OPEN

## On completion

N/A while on HOLD.
