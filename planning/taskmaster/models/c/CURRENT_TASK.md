# CURRENT_TASK

status: OPEN
task_id: C-W4-001
wave: 4
issued: 2026-08-13T03:44:30Z
poll: 2m
title: HANDOFF + snippet-selftest: Containerfile/build.sh hooks still match 0.2.2

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

C-W3-001 locked private-GHCR / dual-DE / catalog tests. Wave 4 is
**merge-prep**: prove HANDOFF + snippets still describe 0.2.2 hooks
(`assistant-builder`, ldflags version, desktop + data COPY). Add or
refresh a snippet-selftest so drift fails closed.

Refresh first:

```bash
git fetch origin
git checkout lane/c-assistant
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/c/
```

## Exclusive paths (only these)

- `apps/hyprwave-assistant/**`
- `build_files/usr/share/hyprwave/assistant/**`
- `build_files/usr/share/applications/hyprwave-assistant.desktop`
- `planning/integration/c-assistant/**`
- `planning/taskmaster/models/c/**`

## Forbidden

- Skel bindings, live `build.sh` / Containerfile, duress enablement, CI, handbook
- Claiming GHCR is public
- Inventing Flathub IDs
- Merging this lane onto main

## Requirements

- [ ] HANDOFF.md still lists 0.2.2 apply order (Containerfile.snippet +
      build.sh.snippet, Super+Shift+A is E/integrator-only)
- [ ] snippet-selftest (new or existing under `planning/integration/c-assistant/`)
      checks snippets mention version `0.2.2`, `assistant-builder`, and
      `/usr/bin/hyprwave-assistant` — FAIL on drift
- [ ] `cd apps/hyprwave-assistant && go test ./...`
- [ ] `bash planning/integration/c-assistant/smoke-host.sh` exit 0
- [ ] Do not edit live Containerfile/build.sh (snippets + HANDOFF only)

## Deliverables

- HANDOFF + snippet-selftest green
- WORK_LOG + COMPLETED

## Done criteria

- [ ] Hooks still 0.2.2; selftest PASS
- [ ] No public-GHCR claim
- [ ] `git push -u origin lane/c-assistant`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
