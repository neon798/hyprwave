# CURRENT_TASK

status: DONE  
task_id: E-W1-002  
wave: 1  
issued: 2026-08-07T04:45:00Z  
title: Lock/idle/theme symlink integrity and session edge cases  

## Objective

Second depth pass on Hyprland session reliability: hyprlock/hypridle coherence, theme indirection symlinks, HiDPI/monitor notes, and edge-case binds — still exclusive to skel + e-hyprland integration docs.

## Exclusive paths

- `build_files/etc/skel/.config/hypr/**`
- `build_files/etc/skel/.config/waybar/**`
- `build_files/etc/skel/.config/walker/**`
- `build_files/etc/skel/.config/mako/**`
- `build_files/etc/skel/.config/ghostty/**` (Hyprland-facing only)
- `build_files/etc/skel/.config/yazi/**`
- `build_files/etc/skel/.config/autostart/**`
- `build_files/etc/skel/.config/systemd/user/**`
- `build_files/etc/skel/.config/hyprwave/**` (theme indirection if present)
- `planning/integration/e-hyprland/**`
- `planning/taskmaster/models/e/**`

## Forbidden

- COSMIC vendor trees (F)
- Duress/Assistant code
- Mass theme pack rewrites under `usr/share/hyprwave/themes` (fix skel symlinks only; HANDOFF for theme pack bugs)
- `build.sh` package installs (HANDOFF only)

## Requirements

- [x] Audit `hyprlock.conf` + `hypridle.conf`: lock keybind exists, idle → lock → DPMS chain documented; no broken paths
- [x] Document theme symlink layout (`~/.config/hyprwave/theme` and per-app links) in `planning/integration/e-hyprland/THEME-SYMLINKS.md`; fix broken skel links if any
- [x] `monitors.conf`: sensible default + comments for multi-monitor / scaling; do not hardcode one user’s layout as silent default if risky
- [x] Walker/mako/waybar: confirm theme-friendly paths; no stale wofi/swaybg
- [x] Expand SESSION-SMOKE.md with lock/idle/theme-switch checks (≥5 new items)
- [x] KEYBIND-MAP.md regenerated/updated if binds change
- [x] HANDOFF.md: any package gaps (hyprshot, etc.) listed for integrator
- [x] ≥3 commits; push `lane/e-hyprland`

## Deliverables

- Skel lock/idle/theme fixes + THEME-SYMLINKS + smoke/map updates

## Done criteria

- [x] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
