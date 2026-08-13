# CURRENT_TASK

status: OPEN
task_id: F-W2-001
wave: 2
issued: 2026-08-13T03:25:00Z
title: COSMIC vendor + greeter vs merged main (wake F)

## Objective

F has been **quiet since 2026-08-07**. COSMIC image CI already succeeded;
local `just build-cosmic` is in flight. Prove vendor defaults and operator
docs match `main`, and prepare a session-smoke card for the new image.

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

## Requirements

- [ ] `bash planning/integration/f-cosmic/check-vendor-paths.sh` exit 0
- [ ] Dock favorites file matches SESSION-SMOKE / GREETER claims:
      neonwolf, flatarcade, Ghostty, CosmicFiles, hyprwave-theme, CosmicSettings
- [ ] Mode `is_dark` + wallpaper vendor keys still present
- [ ] GREETER.md: stock greeter face vs session branding (still true?)
- [ ] SESSION-SMOKE.md: add “image inspect” rows for
      `localhost/hyprwave-cosmic:latest` when the tag is new (cosmic-store
      absent, FlatArcade present, theme GUI present, no SDDM)
- [ ] If local cosmic image exists: `podman run --rm --entrypoint bash
      localhost/hyprwave-cosmic:latest -lc '...'` and record results
- [ ] No cosmic-store regression

## Deliverables

- Vendor script green
- SESSION-SMOKE / GREETER / FREEZE-STATUS stamped 2026-08-13
- WORK_LOG with inspect output or “image not local yet”

## Done criteria

- [ ] check-vendor-paths.sh PASS
- [ ] Docs do not claim SDDM on cosmic
- [ ] `git push -u origin lane/f-cosmic`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
