# CURRENT_TASK

status: DONE
task_id: D-W2-002
wave: 2
issued: 2026-08-13T03:29:05Z
poll: 2m
title: Operator drill (DRILL.md) vs image paths; still OFF

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

D-W2-001 proved the image ships the module and stays PAM-inert. Walk
`planning/integration/d-duress/DRILL.md` against **real image paths**
(`/usr/share/hyprwave/duress`, `/etc/duress.d` empty + README,
`hyprwave-duress-setup`) so an operator can rehearse **without enabling PAM**.

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
- Pre-signing templates; skel; assistant; handbook; CI

## Requirements

- [x] DRILL.md steps match image layout; dry-run / `--help` only — **no**
      `pam_duress` install into `/etc/pam.d`
- [x] Banner: drill is rehearsal; production enable is still operator-only
      (ENABLE.md)
- [x] Paths: `/usr/share/hyprwave/duress`, `/usr/sbin/hyprwave-duress-setup`
      or actual usr-merge path, `/etc/duress.d`
- [x] `bash planning/integration/d-duress/validate.sh` PASS
- [x] `bash planning/qa/run-all.sh --only duress-safety` PASS
- [x] RESIDUALS.md still **OFF**

## Deliverables

- Updated DRILL.md (and OPERATOR-RUNBOOK link if stale)
- Green validate + duress-safety
- WORK_LOG + COMPLETED

## Done criteria

- [x] Drill never enables PAM
- [x] No `*.sha256` templates added
- [x] validate + duress-safety PASS
- [x] `git push -u origin lane/d-duress`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
