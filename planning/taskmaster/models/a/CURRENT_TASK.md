# CURRENT_TASK

status: OPEN
task_id: A-W4-001
wave: 4
issued: 2026-08-13T03:39:11Z
poll: 2m
title: MERGE-READY: pin_guards still pass; list exclusive commits since post-integration-20260807

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

Wave 4 is **merge-prep**, not new features. Make MERGE-READY list the
exclusive commits on `lane/a-stabilize` since `post-integration-20260807`
(or the Wave 1 merge base) and prove pin guards still pass.

Refresh first:

```bash
git fetch origin
git checkout lane/a-stabilize
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/a/
```

## Exclusive paths (only these)

- `build_files/versions.env`
- `build_files/build.sh` (pins / sourcing / checksum **only**)
- `.github/workflows/*`
- `planning/integration/a-stabilize/**`
- `planning/taskmaster/models/a/**`

## Forbidden

- Enabling duress PAM, handbook prose (B), assistant/duress product, skel
- Merging this lane onto main
- Force-push; floating `/releases/latest`

## Requirements

- [ ] `bash planning/qa/run-all.sh --only pins-static` PASS
- [ ] `bash planning/integration/a-stabilize/scripts/verify-pins.sh --head --light`
- [ ] MERGE-READY.md (or INTEGRATION-DAY): commit list + file list vs
      `origin/main` for exclusive paths only
- [ ] GHCR still documented private (403)
- [ ] Do not land unrelated Dependabot majors

## Deliverables

- MERGE-READY commit/file inventory
- Pin verify snippet in WORK_LOG
- COMPLETED line

## Done criteria

- [ ] pins-static PASS
- [ ] Inventory is exclusive-path only
- [ ] `git push -u origin lane/a-stabilize`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
