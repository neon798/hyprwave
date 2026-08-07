# CURRENT_TASK

status: OPEN  
task_id: E-W1-003  
wave: 1  
issued: 2026-08-07T04:55:00Z  
title: Window rules, hyprpaper multi-output, and assistant bind HANDOFF  

## Objective

Polish remaining Hyprland session edges: windowrules rationale completeness, multi-monitor wallpaper notes, and a clear **commented** HANDOFF for Super+Shift+A (Assistant) without implementing Assistant.

## Exclusive paths

- `build_files/etc/skel/.config/hypr/**`
- `build_files/etc/skel/.config/waybar/**`
- `build_files/etc/skel/.config/walker/**`
- `build_files/etc/skel/.config/mako/**`
- `build_files/etc/skel/.config/ghostty/**`
- `build_files/etc/skel/.config/yazi/**`
- `build_files/etc/skel/.config/autostart/**`
- `build_files/etc/skel/.config/systemd/user/**`
- `build_files/etc/skel/.config/hyprwave/**`
- `planning/integration/e-hyprland/**`
- `planning/taskmaster/models/e/**`

## Forbidden

- COSMIC vendor (F), duress, apps/**
- Mass theme pack rewrites
- `build.sh` package installs (HANDOFF only)
- Enabling live Assistant package — only bind comment + HANDOFF line for integrator/C

## Requirements

- [ ] `windowrules.conf`: every rule has rationale comment; walker no-anim present; ThemeSwitcher float preserved
- [ ] `hyprpaper.conf` (+ AUTOSTART/THEME notes): multi-monitor wallpaper behavior documented; no swaybg
- [ ] `bindings.conf`: add **commented** optional Super+Shift+A → hyprwave-assistant line + pointer to C HANDOFF; do not require binary present
- [ ] Update KEYBIND-MAP.md (include commented future bind section)
- [ ] SESSION-SMOKE: + multi-monitor / hyprpaper reload / windowrule spot-checks if practical
- [ ] HANDOFF.md: list integrator steps for Assistant bind uncomment after C merge
- [ ] ≥3 commits; push `lane/e-hyprland`

## Deliverables

- Skel polish + map/smoke/handoff updates

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
