# CURRENT_TASK

status: OPEN  
task_id: F-W1-004  
wave: 1  
issued: 2026-08-07T05:05:00Z  
title: Pre-merge COSMIC freeze + integrator checklist  

## Objective

Freeze COSMIC variant for integration: INTEGRATOR-CHECKLIST, check-vendor-paths green, SESSION-SMOKE/DECLUTTER/GREETER cross-linked as the support pack.

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
- Breaking cosmic-session package set

## Requirements

- [ ] `planning/integration/f-cosmic/INTEGRATOR-CHECKLIST.md` — merge vendor tree + iso notes; run check-vendor-paths; do not reintroduce cosmic-store; smoke link
- [ ] `check-vendor-paths.sh` exit 0
- [ ] README or index under integration/f-cosmic listing DECLUTTER, GREETER, SESSION-SMOKE, THEME-COSMIC-MATRIX, REGENERATE
- [ ] Confirm iso-cosmic.toml bootc ref still `hyprwave-cosmic` story
- [ ] ≥3 commits; push `lane/f-cosmic`

## Deliverables

- INTEGRATOR-CHECKLIST + freeze validation

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
