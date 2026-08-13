# CURRENT_TASK

status: OPEN
task_id: G-W3-001
wave: 3
issued: 2026-08-13T03:33:03Z
poll: 2m
title: check-image.sh --cosmic PASS on localhost/hyprwave-cosmic:latest; residuals VM-only

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

G-W2-003 wired the advisory CI snippet. Wave 3: prove
`check-image.sh --cosmic` against `localhost/hyprwave-cosmic:latest` and
narrow residuals to **VM smoke + GHCR public** only.

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

- [ ] `bash planning/qa/check-image.sh --cosmic` PASS if
      `localhost/hyprwave-cosmic:latest` exists; SKIP (not FAIL) if missing
- [ ] Record output snippet in WORK_LOG
- [ ] ENDPOINT-RESIDUALS / PROGRAM-CLOSEOUT / SMOKE-MATRIX: T8 **image builds
      met**; remaining open = VM qcow2 smokes + anonymous GHCR 403
- [ ] `bash planning/qa/run-all.sh` still RESULT OK
- [ ] Do not claim VM smoke done

## Deliverables

- Cosmic image check PASS or honest SKIP
- Residuals VM + GHCR only
- WORK_LOG + COMPLETED

## Done criteria

- [ ] Harness RESULT OK
- [ ] Residuals no longer list local image build as pending
- [ ] `git push -u origin lane/g-qa`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
