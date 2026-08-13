# CURRENT_TASK

status: OPEN
task_id: C-W5-001
wave: 5
issued: 2026-08-13T04:00:00Z
poll: 2m
title: Post-merge go test (C Wave 2–4 on main)

## Objective

Assistant Waves 2–4 are on `main`. `go test ./...` and snippet-selftest must
pass on the merge tip.

```bash
git fetch origin
git checkout lane/c-assistant
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/c/
```

## Exclusive paths

apps/hyprwave-assistant/** build_files/usr/share/hyprwave/assistant/** planning/integration/c-assistant/** planning/taskmaster/models/c/**

## Done criteria

- [ ] `cd apps/hyprwave-assistant && go test ./...`
- [ ] `bash planning/integration/c-assistant/snippet-selftest.sh` if present
- [ ] `git push -u origin lane/c-assistant`
