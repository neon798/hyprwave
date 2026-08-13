# CURRENT_TASK

status: OPEN
task_id: B-W6-001
wave: 6
issued: 2026-08-13T04:15:00Z
poll: 2m
title: CHANGELOG — Wave 2–4 is on main

## Objective

A–G Waves 2–4 are merged to `main`. Flip CHANGELOG / ISSUES so Unreleased
does not still read like those docs are lane-only. GHCR still not public.

```bash
git fetch origin && git checkout lane/b-docs
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/b/
```

## Exclusive paths

CHANGELOG.md docs/** planning/integration/b-docs/** planning/taskmaster/models/b/**

## Done criteria

- [ ] Dated or Unreleased note: W2–W4 on main; VM smoke still open
- [ ] No GHCR-public / duress-on claims
- [ ] `git push -u origin lane/b-docs`
