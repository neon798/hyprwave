# CURRENT_TASK

status: DONE
task_id: G-W4-001
wave: 4
issued: 2026-08-13T03:44:30Z
poll: 2m
title: probe-merge-conflicts.sh --product-only all lanes vs main; refresh PRE-MERGE-DRY-RUN

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

G-W3-001 proved `check-image.sh --cosmic` and narrowed residuals to VM +
GHCR. Wave 4 is **merge-prep**: re-probe all lanes vs current `origin/main`
(`--product-only`) and refresh PRE-MERGE-DRY-RUN. **A Wave 2–4 is already
merged** (`42450b1`) — record that.

Refresh first:

```bash
git fetch origin
git checkout lane/g-qa
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/g/
```

## Exclusive paths (only these)

- `planning/qa/**`
- `planning/integration/g-qa/**`
- `planning/taskmaster/models/g/**`
- Additive Justfile recipe **only if** you must (prefer `planning/qa/` script)

## Forbidden

- Product skel, cosmic vendor, apps, duress, pins, handbook prose
- Do not edit `.github/workflows/*` (A owns live CI)
- Do not merge other lanes onto main

## Requirements

- [x] `git fetch origin && bash planning/qa/probe-merge-conflicts.sh --product-only`
- [x] PRE-MERGE-DRY-RUN: current lane tip SHAs; note **A already on main**
- [x] Commit probe summary (or honest SKIP if a lane ref is missing)
- [x] `bash planning/qa/run-all.sh` still RESULT OK
- [x] Do not claim VM smoke done; GHCR still private/403

## Deliverables

- Fresh product-only probe + PRE-MERGE-DRY-RUN
- WORK_LOG + COMPLETED

## Done criteria

- [x] Probe run recorded; harness RESULT OK
- [x] Residuals still VM + GHCR only
- [x] `git push -u origin lane/g-qa`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
