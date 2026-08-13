# CURRENT_TASK

status: OPEN
task_id: F-W4-001
wave: 4
issued: 2026-08-13T03:44:30Z
poll: 2m
title: INTEGRATOR-CHECKLIST + vendor script; ISO-cosmic note current

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

F-W3-001 added the ISO-cosmic operator note + inspect reconfirm. Wave 4 is
**merge-prep**: refresh INTEGRATOR-CHECKLIST, keep `check-vendor-paths.sh`
green, and confirm the iso-cosmic.toml note is still current.

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
- Claiming GHCR is public; claiming SDDM on cosmic
- Merging this lane onto main

## Requirements

- [ ] INTEGRATOR-CHECKLIST: vendor script, greeter ≠ SDDM, ISO note, W3 inspect
      SHA/id if known (`189340691cc7` or SKIP if image gone)
- [ ] `bash planning/integration/f-cosmic/check-vendor-paths.sh` exit 0
- [ ] `disk_config/iso-cosmic.toml` still valid TOML; operator blurb current
      (`just build-iso-cosmic`; cosmic-greeter not SDDM)
- [ ] Prefer docs + checklist — no vendor rewrite unless a path is wrong

## Deliverables

- Checklist + vendor script green; ISO note current
- WORK_LOG + COMPLETED

## Done criteria

- [ ] Docs do not claim SDDM on cosmic
- [ ] check-vendor-paths exit 0; iso-cosmic.toml valid
- [ ] `git push -u origin lane/f-cosmic`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
