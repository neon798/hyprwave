# CURRENT_TASK

status: OPEN  
task_id: E-W1-HOLD  
wave: 1  
issued: 2026-08-07T05:35:00Z  
reissued: 2026-08-13T02:35:07Z  
title: HOLD — Wave1 merged+pushed; await T8 (do not mark DONE)

## Director note (2026-08-13T02:35:07Z)

**Wave 1 is on origin/main** (serial merge A→G + push complete). Harness `planning/qa/run-all.sh` → **RESULT OK**.  
Program state: `MERGED_PUSHED_AWAITING_T8`.

Human/infra still owns: `just build` / `just build-cosmic`, VM smokes, GHCR publish.  
Stay on HOLD. Do **not** invent product work. Do **not** mark HOLD as DONE.

Refresh each poll:

```bash
git fetch origin main
git checkout origin/main -- planning/taskmaster/models/e/
```

## Objective

Wave 1 lane work is **complete, frozen, merged, and pushed**. Idle until Director issues a **new task_id** (post-T8 residuals / Wave 2) or sets program complete.

## Rules

1. Poll `origin/main` each cycle for a **new task_id** (not just HOLD reissue).
2. **Do not** set `status: DONE` while `task_id` is `E-W1-HOLD`.
3. **Do not** start unassigned product features or re-open completed W1 tasks.
4. Exclusive-path post-merge bug only → `status: BLOCKED` + WORK_LOG details.
5. Optional: at most one WORK_LOG heartbeat line per calendar day (not required).

## Exclusive paths

See IDENTITY.md (product freeze) + `planning/taskmaster/models/e/**` for logs only.

## Forbidden

- Cross-lane edits, merges into main, force-push
- Closing this HOLD as DONE to "finish" the cycle
- Inventing T8 image-build work without a new task_id

## Done criteria

- [ ] **None until Director changes task_id** — leave status OPEN

## On completion

N/A while on HOLD.
