# CURRENT_TASK

status: OPEN
task_id: G-W5-001
wave: 5
issued: 2026-08-13T04:05:00Z
poll: 2m
title: Post-merge harness + check-image (G Wave 2–4 on main)

## Objective

QA Waves 2–4 are on `main`. Full `run-all.sh` must be RESULT OK; image checks
PASS or SKIP against local tags.

```bash
git fetch origin && git checkout lane/g-qa
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/g/
```

## Exclusive paths

planning/qa/** planning/integration/g-qa/** planning/taskmaster/models/g/**

## Done criteria

- [ ] `bash planning/qa/run-all.sh` RESULT OK
- [ ] check-image hyprland + cosmic PASS if images present
- [ ] `git push -u origin lane/g-qa`
