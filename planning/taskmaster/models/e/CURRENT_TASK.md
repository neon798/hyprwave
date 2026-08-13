# CURRENT_TASK

status: OPEN
task_id: E-W4-001
wave: 4
issued: 2026-08-13T03:39:11Z
poll: 2m
title: INTEGRATION-DAY / SESSION-SMOKE: new-user vs existing-home; KEYBIND-MAP tip SHA

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

Wave 4 is **merge-prep**. Stamp INTEGRATION-DAY / SESSION-SMOKE: skel applies
to **new users only**; existing homes unchanged. Record KEYBIND-MAP tip SHA
for the integrator.

Refresh first:

```bash
git fetch origin
git checkout lane/e-hyprland
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/e/
```

## Exclusive paths (only these)

- `build_files/etc/skel/.config/hypr/**`
- `build_files/etc/skel/.config/waybar/**`
- `build_files/etc/skel/.config/walker/**`
- `build_files/etc/skel/.config/mako/**`
- `build_files/etc/skel/.config/ghostty/**`
- `build_files/etc/skel/.config/yazi/**`
- `build_files/etc/skel/.config/autostart/**`
- `build_files/etc/skel/.config/systemd/user/**`
- `planning/integration/e-hyprland/**`
- `planning/taskmaster/models/e/**`

## Forbidden

- COSMIC vendor, duress, apps/, `build.sh`, wholesale theme rewrites
- Wofi/swaybg/cliphist
- Layout redesign
- Merging this lane onto main

## Requirements

- [ ] INTEGRATION-DAY + SESSION-SMOKE: new-user vs existing-home caveat
- [ ] KEYBIND-MAP: tip SHA of current lane product commit (W3 inspect /
      W2 lock comments)
- [ ] HANDOFF: exclusive file list vs `origin/main` for merge
- [ ] No bind/layout behavior change unless a comment is factually wrong

## Deliverables

- Integration cards + KEYBIND-MAP SHA
- WORK_LOG + COMPLETED

## Done criteria

- [ ] New-user/existing-home is explicit
- [ ] Tip SHA recorded
- [ ] `git push -u origin lane/e-hyprland`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
