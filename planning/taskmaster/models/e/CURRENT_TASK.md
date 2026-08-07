# CURRENT_TASK

status: IN_PROGRESS  
task_id: E-W1-001  
wave: 1  
issued: 2026-08-07T03:50:00Z  
title: Hyprland first-session reliability and keybind coherence  

## Objective

Make a **new user’s first Hyprland session** reliable: autostart order, wallpaper, bar, notifications, launcher, sensible binds, and a written map of every bind. This is UX engineering depth — audit, fix, document.

## Branch setup

```bash
git fetch origin
git checkout -B lane/e-hyprland origin/main   # if branch does not exist yet
```

## Exclusive paths

See IDENTITY.md (skel hypr/waybar/walker/mako/ghostty/yazi/autostart/systemd user).

## Forbidden

- COSMIC vendor trees
- Duress/Assistant code
- Mass theme pack regeneration
- build.sh package installs (file HANDOFF in `planning/integration/e-hyprland/HANDOFF.md`)

## Requirements

- [ ] Audit `autostart.conf` + walker autostart + hyprpaper: document start order in `planning/integration/e-hyprland/AUTOSTART.md`
- [ ] Fix real bugs found (race, missing exec, obsolete swaybg/wofi references)
- [ ] `bindings.conf`: ensure Walker, terminal, yazi, screenshots, theme GUI binds exist and do not conflict; comment sections
- [ ] Produce `planning/integration/e-hyprland/KEYBIND-MAP.md` — every bind → action (machine-readable table)
- [ ] `windowrules.conf`: walker namespace no-anim rule present; add rules only with rationale comments
- [ ] Waybar: modules list documented; no dead modules; style still theme-symlink friendly if applicable
- [ ] Ghostty/yazi: defaults match “default apps” story (Neonwolf is browser — don’t break)
- [ ] `planning/integration/e-hyprland/SESSION-SMOKE.md` — 15 manual checks after login
- [ ] ≥3 commits; push `lane/e-hyprland`

## Deliverables

- Skel fixes + AUTOSTART/KEYBIND-MAP/SESSION-SMOKE docs under integration/e-hyprland

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
