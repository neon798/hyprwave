# CURRENT_TASK

status: DONE
task_id: E-W3-001
wave: 3
issued: 2026-08-13T03:33:03Z
poll: 2m
title: SESSION-SMOKE vs localhost/hyprwave:latest inspect notes; dwindle comments only

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

E-W2-002 cleaned lock/idle comments and waybar tooltips. Wave 3: stamp
SESSION-SMOKE against the **local Hyprland image** and only touch dwindle
layout **comments** (no layout redesign).

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
- No dwindle/layout **behavior** change — comments only

## Requirements

- [x] SESSION-SMOKE inspect notes for localhost/hyprwave:latest (honest PASS/SKIP)
- [x] dwindle comments in hyprland.conf + bindings.conf (looknfeel stays theme symlink)
- [x] Existing-user skel caveat in HANDOFF
- [x] KEYBIND-MAP unchanged (no bind drift)

## Done criteria

- [x] No redesign; no Wofi/swaybg/cliphist
- [x] Inspect notes honest
- [x] `git push -u origin lane/e-hyprland`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
