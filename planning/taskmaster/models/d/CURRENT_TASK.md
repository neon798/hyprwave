# CURRENT_TASK

status: DONE
task_id: D-W4-001
wave: 4
issued: 2026-08-13T03:44:30Z
poll: 2m
title: INTEGRATOR-CHECKLIST + validate.sh green; reaffirm PAM never default-on

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

D-W3-001 added pam-snippet → `/etc/pam.d` negative fixtures. Wave 4 is
**merge-prep**: refresh INTEGRATOR-CHECKLIST against current exclusive
tree and keep validate green. Reaffirm PAM is never default-on.

Refresh first:

```bash
git fetch origin
git checkout lane/d-duress
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/d/
```

## Exclusive paths (only these)

- `build_files/duress/**`
- `build_files/build-duress.sh`
- `planning/integration/d-duress/**`
- `planning/taskmaster/models/d/**`

## Forbidden

- Enabling pam_duress in any default PAM file
- Editing live `build_files/build.sh` (A owns pins; use `build.sh.snippet`
  + validate against tree `build.sh` **read-only**)
- Pre-signing templates; skel; assistant; handbook; CI
- Merging this lane onto main

## Requirements

- [x] INTEGRATOR-CHECKLIST: merge order + **do not enable PAM** still accurate
      after W2–W3 (DRILL paths, N7 pam.d fixtures)
- [x] RESIDUALS.md still **OFF**
- [x] `bash planning/integration/d-duress/validate.sh` PASS
- [x] `bash planning/qa/run-all.sh --only duress-safety` PASS
- [x] No `*.sha256` templates added

## Deliverables

- Checklist refresh + green validate
- WORK_LOG + COMPLETED

## Done criteria

- [x] No default PAM enablement introduced
- [x] validate + duress-safety PASS
- [x] `git push -u origin lane/d-duress`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
