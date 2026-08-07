# CURRENT_TASK

status: DONE  
task_id: C-W1-001  
wave: 1  
issued: 2026-08-07T03:50:00Z  
title: Production-harden Assistant (tests, offline UX, safer system ops)  
completed: 2026-08-07  

## Objective

Take the existing Assistant from “Wave 2 feature-complete skeleton” to **production-hardened**: high test coverage on pure logic, bulletproof dry-run, excellent offline KB UX, and integration snippets that an integrator can apply without guessing.

## Exclusive paths

- `apps/hyprwave-assistant/**`
- `build_files/usr/share/hyprwave/assistant/**`
- `build_files/usr/share/applications/hyprwave-assistant.desktop`
- `planning/integration/c-assistant/**`

## Forbidden

- Editing `build_files/etc/skel/**`
- Editing production `build.sh` / `Containerfile` (snippets only)
- Duress/PAM implementation
- Network calls during `go test`

## Requirements

- [x] `go test ./...` passes; ≥70% coverage on catalog (~90%), kb (~73%), system (~82%)
- [x] Every destructive path has dry-run and double-confirm in TUI (Y twice) and CLI (`--yes --confirm`)
- [x] Offline mode: KB + catalog work offline; updater shows OFFLINE / cannot reach
- [x] Expand KB: first-boot, walker, hyprpaper, dual-variant, troubleshooting
- [x] Catalog: ValidFlatpakID + Validate() on shipped catalog
- [x] Containerfile.snippet static build -trimpath + ldflags; build.sh.snippet installs data + desktop
- [x] HANDOFF-WAVE2.md exact Super+Shift+A bind line
- [x] README covers CLI, env, data paths, testing
- [x] ≥3 commits; push `lane/c-assistant`

## Done criteria

- [x] `cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .` succeeds
- [x] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle until next OPEN task.
