# CURRENT_TASK

status: DONE  
task_id: F-W1-002  
wave: 1  
completed: 2026-08-07T05:00:00Z  
title: Theme-store COSMIC configs audit + wallpaper path proofs  

## Summary

- Inventory: all 11 themes have full `cosmic/config` (30 Dark + 16 Builder); Mode/Background/AppList intentionally pack-omitted (switcher + vendor).
- Vendor wallpaper path proved: repo `wallpapers/default.png` → staged `/usr/share/backgrounds/hyprwave/default.png`; no broken refs.
- Spot-check: vaporwave, fjord-dark, verdant-haven (scene) coherent.
- Docs: THEME-COSMIC-MATRIX.md, SESSION-SMOKE theme-switch items, GREETER reconfirm, REGENERATE note.
- Script: `planning/integration/f-cosmic/check-vendor-paths.sh` (exit 0).
- No themegen regen needed; no vendor config file fixes required.

## On completion

Idle for next OPEN task.
