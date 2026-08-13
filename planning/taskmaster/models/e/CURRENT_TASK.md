# CURRENT_TASK

status: OPEN
task_id: E-W2-002
wave: 2
issued: 2026-08-13T03:29:05Z
poll: 2m
title: hyprlock/hypridle copy + waybar tooltip sanity (no redesign)

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

E-W2-001 locked binds, window rules, and autostart. Small **copy/sanity** pass
on lock/idle comments and waybar tooltips so a new user is not confused.
**No visual redesign.**

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

- COSMIC vendor, duress, apps/, `build.sh`, wholesale theme store rewrites
- Do not reintroduce Wofi/swaybg/cliphist
- No bar/layout redesign

## Requirements

- [ ] `hyprlock.conf` / `hypridle.conf`: comments match real binds
      (Super+Shift+L → loginctl → hypridle `pidof hyprlock || hyprlock`);
      timeout ladder still documented
- [ ] Waybar tooltips / module labels: no Wofi, no “coming soon” Assistant,
      theme/lock/network text matches shipped tools
- [ ] KEYBIND-MAP / SESSION-SMOKE: one-line lock/idle note if drift
- [ ] Existing-user skel caveat stays in HANDOFF
- [ ] Typos/comments only unless a tooltip is factually wrong

## Deliverables

- Comment/tooltip hygiene
- HANDOFF note (what new users see)
- WORK_LOG + COMPLETED

## Done criteria

- [ ] No Wofi/swaybg/cliphist
- [ ] No redesign
- [ ] `git push -u origin lane/e-hyprland`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
