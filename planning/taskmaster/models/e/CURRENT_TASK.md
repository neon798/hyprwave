# CURRENT_TASK

status: OPEN
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
- No dwindle/layout **behavior** change — comments only

## Requirements

- [ ] SESSION-SMOKE: add/refresh inspect notes for
      `localhost/hyprwave:latest` (assistant bind, hyprpaper, walker, 11
      themes, no wofi/swaybg). If image missing, record SKIP — do not invent.
- [ ] `looknfeel.conf` (or layout fragment): dwindle comments match actual
      settings; no gap/border/animation redesign
- [ ] Existing-user skel caveat stays in HANDOFF
- [ ] KEYBIND-MAP only if a comment you add would drift it

## Deliverables

- SESSION-SMOKE inspect addendum
- Optional dwindle comment hygiene
- WORK_LOG + COMPLETED

## Done criteria

- [ ] No redesign; no Wofi/swaybg/cliphist
- [ ] Inspect notes honest (PASS or SKIP)
- [ ] `git push -u origin lane/e-hyprland`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
