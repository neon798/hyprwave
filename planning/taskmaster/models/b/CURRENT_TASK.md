# CURRENT_TASK

status: DONE
task_id: B-W5-001
wave: 5
issued: 2026-08-13T04:00:00Z
completed: 2026-08-13T03:58:00Z
poll: 2m
title: Post-merge handbook check (B Wave 2–4 on main)

## Objective

Handbook Waves 2–4 are on `main`. Re-run the link walk. Confirm Super+Shift+A
and Assistant companions are present. No GHCR-public claim. No duress-on.

```bash
git fetch origin
git checkout lane/b-docs
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/b/
```

## Exclusive paths

INSTALL.md CHANGELOG.md README.md docs/** planning/integration/b-docs/** planning/taskmaster/models/b/**

## Done criteria

- [x] Link walk 0 missing
- [x] Super+Shift+A in keybinds.md
- [x] `git push -u origin lane/b-docs`
