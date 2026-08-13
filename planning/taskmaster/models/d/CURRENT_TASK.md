# CURRENT_TASK

status: DONE
task_id: D-W3-001
wave: 3
issued: 2026-08-13T03:35:03Z
poll: 2m
title: Extra negative fixture: build.sh must not copy pam snippets to /etc/pam.d

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

D-W2-002 aligned DRILL.md with image paths (still OFF). Wave 3: add a
**negative fixture** so validate/snippet-selftest FAIL if `build.sh` (or the
duress snippet) would install pam snippets into `/etc/pam.d`.

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

## Requirements

- [x] Extend `validate.sh` and/or `snippet-selftest.sh`: FAIL if snippet or
      `build.sh` copies `pam.d` / `pam_duress` into `/etc/pam.d`
- [x] Do not change production enablement; stay OFF
- [x] `bash planning/integration/d-duress/validate.sh` PASS
- [x] `bash planning/qa/run-all.sh --only duress-safety` PASS
- [x] RESIDUALS.md still **OFF**

## Deliverables

- Negative fixture + green validate
- WORK_LOG + COMPLETED

## Done criteria

- [x] No default PAM enablement introduced
- [x] No `*.sha256` templates added
- [x] validate + duress-safety PASS
- [x] `git push -u origin lane/d-duress`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
