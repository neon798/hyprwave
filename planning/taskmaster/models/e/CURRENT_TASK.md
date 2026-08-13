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

```bash
git fetch origin
git checkout lane/e-hyprland
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/e/
```

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

## Result (2026-08-13T05:33Z)

- **main tip:** `c712cbd` (includes `878d38e` merge of lane Wave 2–4)
- **Lane:** merged/up-to-date with `origin/main`; product skel identical for bindings
- **Binds:** 87 active; SUPER+SHIFT+A (assistant), SUPER+SHIFT+T (theme-gui), SUPER+SHIFT+E (exit) match KEYBIND-MAP
- **Forbidden:** no cliphist/wofi/swaybg under skel
- Idle until director issues a new task_id
