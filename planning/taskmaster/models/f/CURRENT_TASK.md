# CURRENT_TASK

status: OPEN
task_id: F-W3-001
wave: 3
issued: 2026-08-13T03:33:03Z
poll: 2m
title: ISO-cosmic.toml operator note + SESSION-SMOKE image-inspect results committed

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

F-W2-002 added IMAGE-INSPECT.md. Wave 3: operator note on
`disk_config/iso-cosmic.toml` (how to build the COSMIC ISO) and **commit**
SESSION-SMOKE / inspect results from `localhost/hyprwave-cosmic:latest`.

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

- [ ] Comment or short operator blurb for `iso-cosmic.toml`: used by
      `just build-iso-cosmic`; cosmic-greeter not SDDM; do not claim GHCR public
- [ ] SESSION-SMOKE / IMAGE-INSPECT: commit actual inspect output (or SKIP if
      image missing). Expected: cosmic-greeter, no cosmic-store, FlatArcade,
      theme GUI, no SDDM required
- [ ] `bash planning/integration/f-cosmic/check-vendor-paths.sh` still exit 0
      if you touch vendor files (prefer docs + toml comments)

## Deliverables

- ISO operator note + committed inspect results
- WORK_LOG + COMPLETED

## Done criteria

- [ ] Docs do not claim SDDM on cosmic
- [ ] iso-cosmic.toml still valid TOML
- [ ] `git push -u origin lane/f-cosmic`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
