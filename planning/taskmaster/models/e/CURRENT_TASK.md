# CURRENT_TASK

status: OPEN
task_id: E-W2-001
wave: 2
issued: 2026-08-13T03:25:00Z
poll: 2m
title: Hyprland session hardening (assistant + day-1 UX)

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

Hyprland image builds. Make the **new-user session** feel finished: binds,
window rules, autostart, Walker/waybar. Existing homes are not rewritten —
document that in HANDOFF, do not write a destructive migrator.

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

## Requirements

- [ ] Confirm Super+Shift+A → assistant, Super+Shift+T → theme GUI,
      Super+Shift+E exit, Super+D/Space Walker, Super+R runner — all in
      `bindings.conf`; refresh KEYBIND-MAP if drift
- [ ] Window rules: assistant (Ghostty `-e hyprwave-assistant`) and
      `hyprwave-theme-gui` should not look broken (float/center if that matches
      existing style — justify in comments)
- [ ] Autostart: elephant + walker + waybar + mako + hyprpaper + hypridle;
      no cliphist
- [ ] Walker emergencies still restart `app-walker@autostart.service`
- [ ] SESSION-SMOKE.md / HANDOFF: existing-user skel caveat; image
      `localhost/hyprwave:latest` exists
- [ ] Small UX bugs only (typos, missing comments, one bind). No redesign.

## Deliverables

- Skel + KEYBIND-MAP in sync
- SESSION-SMOKE updated for Wave 2
- HANDOFF for integrator (what changed for new users)

## Done criteria

- [ ] No Wofi/swaybg/cliphist
- [ ] KEYBIND-MAP matches `bindings.conf`
- [ ] `git push -u origin lane/e-hyprland`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
