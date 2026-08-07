# CURRENT_TASK

status: DONE  
task_id: B-W1-003  
wave: 1  
issued: 2026-08-07T04:55:00Z  
title: Security/docs alignment + screenshot ops + dual-variant troubleshooting  

## Objective

Close remaining handbook gaps toward ENDPOINT: security docs match duress packaging truth (read D lane), screenshot ops are executable notes, troubleshooting covers both DE variants cleanly.

## Exclusive paths

- `INSTALL.md`, `CHANGELOG.md`, `README.md`
- `docs/**`
- `planning/integration/b-docs/**`
- `planning/taskmaster/models/b/**`

## Forbidden

- Editing `build_files/**`
- Claiming duress enabled by default
- Claiming GHCR public unless verified
- Product code outside docs

## Requirements

- [x] `docs/security.md` aligned with `origin/lane/d-duress` ENABLE/FAQ/THREAT-MODEL (read-only): off-by-default, residual risks, no LUKS claims
- [x] Expand `docs/troubleshooting.md` dual-variant matrix (Hyprland greeter/session vs COSMIC; Walker vs cosmic launcher; theme switcher both)
- [x] `planning/integration/b-docs/screenshot-checklist.md`: every item has purpose + alt text + **exact capture command** (grim/hyprshot notes); mark blockers if host has no compositor
- [x] Optional short `docs/screenshots.md` index linking checklist + where assets will live (`docs/assets/` reserved, do not commit huge binaries unless tiny placeholders)
- [x] README “Docs” section lists first-boot + keybinds + security
- [x] Relative link check clean; ACCURACY-AUDIT updated
- [x] ≥3 commits; push `lane/b-docs`

## Deliverables

- Security/troubleshooting polish, screenshot ops readiness, audit update

## Done criteria

- [x] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Set DONE, log, idle for next task.
