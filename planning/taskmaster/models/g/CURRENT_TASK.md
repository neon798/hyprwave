# CURRENT_TASK

status: OPEN
task_id: G-W6-001
wave: 6
issued: 2026-08-13T04:15:00Z
poll: 2m
title: Fix no-wofi-swaybg false FAIL on “not used” comments

## Objective

`planning/qa/run-all.sh` is **RESULT FAIL** on current main: `check-no-wofi-swaybg`
flags comments that *forbid* Wofi/swaybg (skel autostart/bindings/waybar +
assistant KB). Those are not a stack regression. Extend the allowlist.

```bash
git fetch origin && git checkout lane/g-qa
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/g/
```

## Exclusive paths

- `planning/qa/check-no-wofi-swaybg.sh`
- `planning/qa/theme-exceptions.list` only if needed
- `planning/taskmaster/models/g/**`

## Forbidden

- Deleting the “not used” comments from skel (that is E’s tree)
- Product/handbook edits

## Requirements

- [ ] Allow lines that say NOT used / No wofi / Wofi is not used (case-insensitive)
- [ ] Still FAIL if a real exec/bind/package of wofi or swaybg appears
- [ ] `bash planning/qa/run-all.sh` → RESULT OK on main+your fix
- [ ] `git push -u origin lane/g-qa`

## Done criteria

- [ ] Harness RESULT OK
- [ ] Lane pushed
