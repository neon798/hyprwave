# CURRENT_TASK

status: OPEN
task_id: D-W5-001
wave: 5
issued: 2026-08-13T04:05:00Z
poll: 2m
title: Post-merge validate.sh (D Wave 2–4 on main)

## Objective

Duress Waves 2–4 are on `main`. Re-run validate + duress-safety. PAM still OFF.

```bash
git fetch origin && git checkout lane/d-duress
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/d/
```

## Exclusive paths

build_files/duress/** build_files/build-duress.sh planning/integration/d-duress/** planning/taskmaster/models/d/**

## Done criteria

- [ ] `bash planning/integration/d-duress/validate.sh` PASS
- [ ] `bash planning/qa/run-all.sh --only duress-safety` PASS
- [ ] `git push -u origin lane/d-duress`
