# CURRENT_TASK

status: OPEN  
task_id: C-W1-003  
wave: 1  
issued: 2026-08-07T05:05:00Z  
title: Pre-merge Assistant freeze + integrator smoke script  

## Objective

Freeze Assistant for integration wave: packaging self-check script, coverage snapshot, final HANDOFF one-pager, no new feature sprawl.

## Exclusive paths

- `apps/hyprwave-assistant/**`
- `build_files/usr/share/hyprwave/assistant/**`
- `build_files/usr/share/applications/hyprwave-assistant.desktop`
- `planning/integration/c-assistant/**`
- `planning/taskmaster/models/c/**`

## Forbidden

- Editing skel (E owns Super+Shift+A uncomment)
- Editing production build.sh/Containerfile (snippets only)
- Duress/PAM
- Network in `go test`

## Requirements

- [ ] `planning/integration/c-assistant/smoke-host.sh` — runs `go test ./...`, builds with ldflags, runs `--help`/`--version`/`kb`/`list`/`update --dry-run` (exit 0)
- [ ] `HANDOFF.md` one-pass: snippet apply order, data paths, Super+Shift+A line for E, package deps if any
- [ ] Coverage snapshot in WORK_LOG for catalog/kb/system (or `go test -cover`)
- [ ] Confirm desktop + catalog.toml + all KB files listed in README install layout
- [ ] Version string / RELEASE-NOTES consistent (0.2.2 or bump if needed)
- [ ] ≥3 commits; push `lane/c-assistant`

## Deliverables

- smoke-host.sh + HANDOFF freeze + tests green

## Done criteria

- [ ] `bash planning/integration/c-assistant/smoke-host.sh` exits 0
- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
