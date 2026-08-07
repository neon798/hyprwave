# CURRENT_TASK

status: DONE  
task_id: F-W1-001  
wave: 1  
issued: 2026-08-07T03:50:00Z  
title: COSMIC vendor-default audit and greeter/session cohesion  

## Objective

Verify and improve the **COSMIC** variant’s Hyprwave identity: dock favorites, wallpaper, theme keys, declutter story, and greeter expectations — with written proof of what the image should contain.

## Branch setup

```bash
git fetch origin
git checkout -B lane/f-cosmic origin/main
```

## Exclusive paths

See IDENTITY.md.

## Forbidden

- Hyprland skel rewrites
- Removing packages that break cosmic-session (e.g. cosmic-term hard dep)
- Enabling duress
- Touching Yazi/Neonwolf pin URLs (A)

## Requirements

- [x] Inventory every file under `build_files/usr/share/cosmic/` in `planning/integration/f-cosmic/VENDOR-INVENTORY.md` (path → purpose)
- [x] Confirm favorites include Neonwolf, FlatArcade, Ghostty, CosmicFiles, CosmicSettings (or document intentional diffs)
- [x] Background/wallpaper keys point at Hyprwave wallpaper paths that exist in repo
- [x] Theme Dark keys match Hyprwave palette (document hex vs RON fields)
- [x] `planning/integration/f-cosmic/SESSION-SMOKE.md` — COSMIC first-login checklist (≥12 items)
- [x] `planning/integration/f-cosmic/GREETER.md` — cosmic-greeter expectations, wallpaper, known limits
- [x] iso-cosmic.toml reviewed; comments for image name / kickstart-like notes if applicable
- [x] If build.sh cosmic case needs a fix: either minimal edit only in `cosmic)` arm **or** snippet + HANDOFF — note choice in WORK_LOG
- [x] Optional: regenerate notes for themegen without committing `target/`
- [x] ≥3 commits; push `lane/f-cosmic`

## Deliverables

- Inventory, smoke, greeter docs; any justified vendor file fixes

## Done criteria

- [x] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
