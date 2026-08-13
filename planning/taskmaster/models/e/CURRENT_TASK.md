# CURRENT_TASK

status: DONE
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

- [x] `hyprlock.conf` / `hypridle.conf`: comments match Super+Shift+L → loginctl → `pidof hyprlock || hyprlock`; timeout ladder documented
- [x] Waybar tooltips: no Wofi, no “coming soon” Assistant; network/pulse/bt name shipped tools
- [x] KEYBIND-MAP / SESSION-SMOKE lock/idle one-liners
- [x] Existing-user skel caveat stays in HANDOFF
- [x] Typos/comments only (no redesign)

## Deliverables

- Comment/tooltip hygiene
- HANDOFF note (what new users see)
- WORK_LOG + COMPLETED

## Done criteria

- [x] No Wofi/swaybg/cliphist
- [x] No redesign
- [x] `git push -u origin lane/e-hyprland`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
