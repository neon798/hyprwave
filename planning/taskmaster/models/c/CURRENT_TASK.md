# CURRENT_TASK

status: OPEN  
task_id: C-W1-002  
wave: 1  
issued: 2026-08-07T04:45:00Z  
title: Integrator-ready package surface + offline UX polish + versioned release notes  

## Objective

Make Assistant **drop-in ready** for the integration wave: complete data install tree, versioned binary story, offline-first UX polish, and handoff that an integrator can apply in one pass without inventing paths.

## Exclusive paths

- `apps/hyprwave-assistant/**`
- `build_files/usr/share/hyprwave/assistant/**`
- `build_files/usr/share/applications/hyprwave-assistant.desktop`
- `planning/integration/c-assistant/**`
- `planning/taskmaster/models/c/**`

## Forbidden

- Editing `build_files/etc/skel/**`
- Editing production `build.sh` / `Containerfile` (snippets only)
- Duress/PAM implementation
- Network calls during `go test`

## Requirements

- [ ] Ensure KB + catalog data under `build_files/usr/share/hyprwave/assistant/` is complete and matches what the binary expects (document install layout in README)
- [ ] Desktop file: sensible Name/Comment/Exec/Categories/Terminal if TUI; Icon if available or HANDOFF for icon asset
- [ ] Snippets: `build.sh.snippet` + `Containerfile.snippet` install binary **and** data + desktop in one documented flow; version via ldflags; `-trimpath`
- [ ] `HANDOFF.md` / `HANDOFF-WAVE2.md`: exact Super+Shift+A bind line for E; package deps if any; post-install smoke (`hyprwave-assistant --help`, kb list)
- [ ] CLI: `--version` works; help text lists update/install/kb/dry-run/confirm flags; destructive ops still require dry-run + double-confirm
- [ ] ≥2 new or substantially expanded KB articles (e.g. FlatArcade, theming, dual DE, bootc rebase user story)
- [ ] `go test ./...` still passes; keep coverage discipline on catalog/kb/system
- [ ] `planning/integration/c-assistant/RELEASE-NOTES-0.2.md` (or similar) for integrator CHANGELOG blurb
- [ ] ≥3 commits; push `lane/c-assistant`

## Deliverables

- Complete share tree + snippets + handoff + KB expansions + tests green

## Done criteria

- [ ] `cd apps/hyprwave-assistant && go test ./... && go build -ldflags "-X main.version=test" -o /tmp/hyprwave-assistant .` succeeds
- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle until next OPEN task.
