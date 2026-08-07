# CURRENT_TASK

status: OPEN  
task_id: C-W1-001  
wave: 1  
issued: 2026-08-07T03:50:00Z  
title: Production-harden Assistant (tests, offline UX, safer system ops)  

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

- [ ] `go test ./...` passes; add tests until **≥70%** coverage on `internal/catalog`, `internal/kb`, and command-building paths under `internal/system` (or document measured % and gap plan if tool limits)
- [ ] Every destructive path has dry-run and double-confirm in TUI **and** CLI
- [ ] Offline mode: KB + catalog work with no network; updater shows clear “cannot reach” states
- [ ] Expand KB: first-boot, walker, hyprpaper, dual-variant, troubleshooting (≥3 new or substantially expanded articles)
- [ ] Catalog: only real Flathub IDs; validate with a small Go test or script that checks ID format
- [ ] `Containerfile.snippet` builds a static-ish binary with `-trimpath` and version ldflags; `build.sh.snippet` installs data + desktop file
- [ ] `HANDOFF-WAVE2.md` (or HANDOFF.md) lists exact skel keybind line for Super+Shift+A — do not edit skel
- [ ] README in apps/ covers CLI, env vars, data paths, testing
- [ ] ≥3 commits; push `lane/c-assistant`

## Deliverables

- Hardened Go tree + tests
- Richer KB/catalog
- Updated integration snippets + handoff

## Done criteria

- [ ] `cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .` succeeds
- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle until next OPEN task.
