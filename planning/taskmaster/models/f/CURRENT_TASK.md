# CURRENT_TASK

status: OPEN  
task_id: F-W1-002  
wave: 1  
issued: 2026-08-07T04:45:00Z  
title: Theme-store COSMIC configs audit + wallpaper path proofs  

## Objective

Ensure every Hyprwave theme that ships COSMIC config is coherent, wallpapers resolve, and greeter/session docs match vendor keys — toward ENDPOINT “COSMIC feels on-brand.”

## Exclusive paths

- `build_files/usr/share/cosmic/**`
- `disk_config/iso-cosmic.toml`
- COSMIC-only `build_files/build.sh` `cosmic)` arm only if essential (prefer docs/snippets)
- `planning/bin/generate-cosmic-themes.sh` / `planning/bin/themegen/**` (no huge `target/` commits)
- `build_files/usr/share/hyprwave/themes/*/cosmic/**` (theme cosmic configs only — not Hyprland skel)
- `planning/integration/f-cosmic/**`
- `planning/taskmaster/models/f/**`

## Forbidden

- Hyprland skel rewrites
- Shared pin URLs (A)
- Duress / Assistant
- Removing packages that break cosmic-session

## Requirements

- [ ] Inventory which themes under `build_files/usr/share/hyprwave/themes/*` include `cosmic/config/`; table in `planning/integration/f-cosmic/THEME-COSMIC-MATRIX.md`
- [ ] For default/system vendor path: prove wallpaper file(s) exist in repo; fix broken references
- [ ] Spot-check 2–3 non-default themes’ cosmic configs for required keys (Mode, Background, dock favorites or document intentional minimal sets)
- [ ] If themegen needed: document regenerate steps in REGENERATE.md; commit only generated configs (not `target/`)
- [ ] Expand SESSION-SMOKE.md with theme-switch / wallpaper checks for COSMIC
- [ ] GREETER.md: confirm wallpaper/branding expectations vs what greeter can show
- [ ] Optional: small shell check script under `planning/integration/f-cosmic/check-vendor-paths.sh` (wallpaper exists, favorites IDs non-empty)
- [ ] ≥3 commits; push `lane/f-cosmic`

## Deliverables

- THEME-COSMIC-MATRIX, path proofs, any justified config fixes, smoke/greeter updates

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
