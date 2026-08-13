# CURRENT_TASK

status: OPEN
task_id: C-W3-001
wave: 3
issued: 2026-08-13T03:37:13Z
poll: 2m
title: Assistant tests for private-GHCR / dual-DE copy; catalog IDs still real

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

C-W2-002 polished About/preflight for private GHCR. Wave 3: **lock that in
with tests** — private-GHCR / dual-DE copy cannot regress; catalog Flathub
IDs stay real.

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

- Skel bindings, `build.sh` / Containerfile, duress enablement, CI, handbook
- Claiming GHCR is public
- Inventing Flathub IDs

## Requirements

- [ ] Tests (kb/cli/preflight/catalog as appropriate) assert:
      private/auth GHCR language; localhost tags valid; dual DE; Super+Shift+A;
      no Wofi/swaybg; duress not enabled
- [ ] Catalog IDs used in tests/docs still match real Flathub apps
- [ ] `cd apps/hyprwave-assistant && go test ./...`
- [ ] `bash planning/integration/c-assistant/smoke-host.sh` exit 0

## Deliverables

- Regression tests + green go test / smoke-host
- WORK_LOG + COMPLETED

## Done criteria

- [ ] `go test ./...` PASS
- [ ] No public-GHCR claim
- [ ] `git push -u origin lane/c-assistant`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
