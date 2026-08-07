# CURRENT_TASK

status: DONE  
task_id: B-W1-002  
wave: 1  
issued: 2026-08-07T04:45:00Z  
title: Keybind accuracy sync, first-boot handbook chapter, release notes polish  

## Objective

Drive docs toward ENDPOINT accuracy: keybinds match Hyprland reality (read E’s KEYBIND-MAP / skel on `origin/lane/e-hyprland` **read-only**), a complete first-boot chapter, and CHANGELOG/INSTALL that reflect **pending multi-lane merge** honestly.

## Exclusive paths

- `INSTALL.md`, `CHANGELOG.md`, `README.md`
- `docs/**`
- `planning/integration/b-docs/**`
- `planning/taskmaster/models/b/**`

## Forbidden

- Editing `build_files/**`
- Claiming duress enabled by default
- Claiming GHCR public unless verified
- Inventing binds not present in skel (prefer `git show origin/lane/e-hyprland:…`)

## Requirements

- [x] `docs/keybinds.md` reconciled against `origin/lane/e-hyprland` `bindings.conf` + `planning/integration/e-hyprland/KEYBIND-MAP.md` (read-only); note COSMIC differences
- [x] New or expanded `docs/first-boot.md` — login → wallpaper/bar/launcher → terminal/browser/store → theme switcher → update story; link A’s FIRST-BOOT-CHECKLIST
- [x] INSTALL.md: dual-variant (Hyprland vs COSMIC) decision tree + ISO vs rebase; private GHCR contingency still accurate
- [x] CHANGELOG Unreleased: list Wave-1 lane deliverables as **pending merge** where not on main; no false “shipped on main” claims
- [x] `docs/cosmic.md` cross-links F greeter/session smoke when present on `origin/lane/f-cosmic` (paths as “on lane” if not merged)
- [x] Update `planning/integration/b-docs/ACCURACY-AUDIT.md` with keybind + first-boot sources checked
- [x] Relative link check remains clean
- [x] ≥3 commits; push `lane/b-docs`

## Deliverables

- first-boot chapter, keybind sync, CHANGELOG/INSTALL honesty pass, audit update

## Done criteria

- [x] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Set DONE, log, idle for next task.
