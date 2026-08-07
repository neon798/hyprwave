# CURRENT_TASK

status: OPEN  
task_id: F-W1-003  
wave: 1  
issued: 2026-08-07T04:55:00Z  
title: Declutter proof, ISO final notes, FlatArcade-on-COSMIC smoke  

## Objective

Lock COSMIC variant story for integration: prove declutter intent, finalize iso-cosmic operator notes, and expand smoke for FlatArcade/Ghostty/Neonwolf on COSMIC — still no Hyprland skel churn.

## Exclusive paths

- `build_files/usr/share/cosmic/**`
- `disk_config/iso-cosmic.toml`
- COSMIC-only `build_files/build.sh` `cosmic)` arm only if essential
- `planning/bin/generate-cosmic-themes.sh` / `planning/bin/themegen/**` (no huge `target/`)
- `build_files/usr/share/hyprwave/themes/*/cosmic/**`
- `planning/integration/f-cosmic/**`
- `planning/taskmaster/models/f/**`

## Forbidden

- Hyprland skel, pins (A), duress, Assistant app code
- Removing packages that break cosmic-session

## Requirements

- [ ] `planning/integration/f-cosmic/DECLUTTER.md` — list packages intentionally removed/avoided in cosmic arm (from build.sh read-only or HANDOFF); warn about `--no-autoremove`; what must remain
- [ ] `disk_config/iso-cosmic.toml`: final comment block for image name, expected bootc ref, known installer limits
- [ ] Expand SESSION-SMOKE: FlatArcade launch, Ghostty, Neonwolf, Settings, Files, network, theme switch (≥6 new or refined items)
- [ ] `check-vendor-paths.sh` still exit 0; extend lightly if declutter docs claim wallpapers/favorites
- [ ] GREETER.md: one-pass “day-1 COSMIC” expectation vs Hyprland for support docs (B can link later)
- [ ] ≥3 commits; push `lane/f-cosmic`

## Deliverables

- DECLUTTER.md, ISO notes, smoke/greeter updates, check script still green

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
