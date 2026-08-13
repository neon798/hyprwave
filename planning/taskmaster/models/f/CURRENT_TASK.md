# CURRENT_TASK

status: OPEN
task_id: F-W2-002
wave: 2
issued: 2026-08-13T03:27:11Z
poll: 2m
title: Cosmic image inspect card after localhost/hyprwave-cosmic:latest is new

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

F-W2-001 stamped vendor + greeter docs. Local image **exists**:
`localhost/hyprwave-cosmic:latest` (`189340691cc7`, inspect OK). Produce a
durable **image inspect card** (copy-paste `podman run` + expected facts) so
the next rebuild can be re-checked without rediscovering commands.

Refresh first:

```bash
git fetch origin
git checkout lane/f-cosmic
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/f/
```

## Exclusive paths (only these)

- `build_files/usr/share/cosmic/**`
- `disk_config/iso-cosmic.toml`
- COSMIC-only `build.sh` `cosmic)` arm **only if required** (prefer snippets
  under `planning/integration/f-cosmic/`)
- `planning/bin/generate-cosmic-themes.sh` (do not commit `themegen/target/`)
- `planning/integration/f-cosmic/**`
- `planning/taskmaster/models/f/**`

## Forbidden

- Hyprland skel, duress, assistant app, shared pin section of build.sh
- Do not merge other lanes onto main

## Requirements

- [ ] Add or finish `planning/integration/f-cosmic/IMAGE-INSPECT.md` (or a
      clearly marked section in SESSION-SMOKE):
      image ref, digest if known, commands, expected: cosmic-greeter present,
      **no** SDDM required, **no** cosmic-store, FlatArcade + theme GUI present,
      vendor favorites / wallpaper keys
- [ ] Re-run inspect against `localhost/hyprwave-cosmic:latest` if the tag
      exists; if missing, SKIP and record — do not FAIL the lane
- [ ] Cross-link GREETER.md / SESSION-SMOKE / FREEZE-STATUS (still no SDDM)
- [ ] Vendor path script still exit 0 if you touch vendor files (prefer docs-only)

## Deliverables

- IMAGE-INSPECT (or equivalent) card with recorded output snippet
- WORK_LOG + COMPLETED

## Done criteria

- [ ] Inspect card is re-runnable
- [ ] Docs do not claim SDDM on cosmic
- [ ] `git push -u origin lane/f-cosmic`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
