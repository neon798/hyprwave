# CURRENT_TASK

status: DONE  
task_id: E-W1-004  
wave: 1  
issued: 2026-08-07T05:05:00Z  
title: Pre-merge Hyprland session freeze + bind map audit  

## Objective

Freeze Hyprland skel for integration: KEYBIND-MAP matches bindings exactly, SESSION-SMOKE is the operator gate, HANDOFF lists only real residuals (Assistant uncomment).

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

- COSMIC vendor, duress, apps/**
- Mass theme pack rewrites
- Enabling live Assistant bind without binary on image (keep commented)

## Requirements

- [x] Diff KEYBIND-MAP.md against `bindings.conf` — zero silent drift; include commented Super+Shift+A section
- [x] SESSION-SMOKE.md: numbered final gate (≥20 items) suitable for post-merge VM
- [x] HANDOFF.md: only Assistant uncomment + any package residual (or “none”)
- [x] Grep skel for wofi/swaybg/rofi — must be clean
- [x] ≥3 commits; push `lane/e-hyprland`

## Deliverables

- Frozen map/smoke/handoff (+ tiny skel fixes only if audit finds bugs)

## Done criteria

- [x] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
