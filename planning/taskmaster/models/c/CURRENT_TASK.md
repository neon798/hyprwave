# CURRENT_TASK

status: DONE
task_id: C-W2-001
wave: 2
issued: 2026-08-13T03:25:00Z
poll: 2m
title: Assistant day-1 KB + catalog vs shipped OS

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

Assistant **0.2.2 is in the Hyprland image** (`/usr/bin` usr-merge). KB/catalog
still read like pre-merge theory in places. Make offline help match the OS that
actually shipped.

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

- Skel bindings (already Super+Shift+A on main — HANDOFF only)
- `build.sh` / Containerfile (snippets only if a real hook bug)
- Duress enablement, CI, handbook

## Requirements

- [ ] Re-read KB pages; fix any “pending merge”, Wofi/swaybg, or “assistant not
      installed” claims
- [ ] KB must state: dual DE, Walker/hyprpaper, 11 themes, duress **OFF**,
      GHCR may be private, skel = new users only, Super+Shift+A
- [ ] Add/refresh pages if missing: first-boot, GHCR/private pull, COSMIC vs
      Hyprland (do not duplicate whole handbook — short, actionable)
- [ ] Catalog: keep Flathub IDs real; add 1–2 clearly missing day-1 apps only
      if IDs are verified (do not invent)
- [ ] `cd apps/hyprwave-assistant && go test ./...`
- [ ] Update `planning/integration/c-assistant/smoke-host.sh` / HANDOFF if stale
- [ ] Desktop entry Name/Comment accurate

## Deliverables

- Corrected KB + catalog
- Green `go test`
- HANDOFF note: image-hooked 0.2.2 verified on `localhost/hyprwave:latest`

## Done criteria

- [ ] `go test ./...` PASS
- [ ] No Wofi/swaybg/Thunar-as-default in assistant KB
- [ ] Duress not described as enabled
- [ ] `git push -u origin lane/c-assistant`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work


## Completion

status: DONE  
completed: 2026-08-13T03:28:12Z  
notes: Day-1 KB/catalog aligned with shipped OS; smoke-host + go test green; HANDOFF notes image-hooked 0.2.2 on localhost/hyprwave:latest.
