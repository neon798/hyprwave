# CURRENT_TASK

status: OPEN
task_id: C-W2-002
wave: 2
issued: 2026-08-13T03:29:05Z
poll: 2m
title: Assistant About/preflight polish; bootc status copy matches private GHCR

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

C-W2-001 aligned KB/catalog with the shipped OS. Polish **About** +
**preflight / `status --check`** so `bootc status` copy does not tell the user
to pull a public GHCR image (anonymous pull is still **403**).

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

- Skel bindings, `build.sh` / Containerfile (snippets only), duress enablement,
  CI, handbook
- Claiming GHCR is public

## Requirements

- [ ] About tab / `--version` strings: dual DE, assistant 0.2.2, Super+Shift+A;
      no “not installed” / Wofi / swaybg
- [ ] `hyprwave-assistant status [--check]` / preflight: if image ref is GHCR,
      say private/auth may be required; localhost tags are valid
- [ ] KB `updates.md` / `ghcr.md` stay consistent with private GHCR
- [ ] `cd apps/hyprwave-assistant && go test ./...`
- [ ] `bash planning/integration/c-assistant/smoke-host.sh` still exit 0

## Deliverables

- About + preflight copy fix
- Green `go test` + smoke-host
- WORK_LOG + COMPLETED

## Done criteria

- [ ] `go test ./...` PASS
- [ ] No public-GHCR install claim in About/preflight
- [ ] `git push -u origin lane/c-assistant`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
