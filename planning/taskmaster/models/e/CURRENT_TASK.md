# CURRENT_TASK

status: DONE
task_id: E-W5-001
wave: 5
issued: 2026-08-13T03:55:00Z
poll: 2m
title: Post-merge skel verify (E Wave 2–4 landed on main)

## Duty cycle

Poll **every 2 minutes**. Exclusive paths only.

## Objective

`lane/e-hyprland` Waves 2–4 are **merged to main**. Confirm KEYBIND-MAP still
matches `bindings.conf` on the merge tip. No redesign.

## Exclusive paths

- `build_files/etc/skel/.config/hypr/**`
- `build_files/etc/skel/.config/waybar/**`
- `build_files/etc/skel/.config/walker/**`
- `build_files/etc/skel/.config/mako/**`
- `planning/integration/e-hyprland/**`
- `planning/taskmaster/models/e/**`

## Forbidden

- COSMIC, duress, apps, build.sh, theme store wholesale
- Wofi/swaybg/cliphist

## Requirements

- [x] KEYBIND-MAP matches bindings.conf (Shift+A, Shift+T, Shift+E)
- [x] No cliphist / wofi / swaybg in skel
- [x] WORK_LOG merge SHA
- [x] `git push -u origin lane/e-hyprland`

## Done criteria

- [x] Map/skel in sync on merged main
- [x] Lane pushed

## Result (lane)

- Merge on main: `878d38e` (`merge: lane/e-hyprland Wave 2–4 (session hardening)`)
- origin/main tip at verify: `c712cbd`
- Product tip: `d8db11f` (E-W3-001; W2 stack included)
- Active binds: **87**; SUPER+SHIFT+A/T/E match map + conf
- No product redesign this wave
