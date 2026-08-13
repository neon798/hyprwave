# CURRENT_TASK

status: OPEN
task_id: G-W2-001
wave: 2
issued: 2026-08-13T03:25:00Z
title: Container image smoke check + T8 residual update

## Objective

Host tree harness is green. We now have `localhost/hyprwave:latest` (and soon
cosmic). Add a **skip-if-missing** image inspect check so T8 is automated next
time, and flip ENDPOINT residuals to match CI + local build.

Refresh first:

```bash
git fetch origin
git checkout lane/g-qa
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/g/
```

## Exclusive paths (only these)

- `planning/qa/**`
- `planning/integration/g-qa/**`
- `planning/taskmaster/models/g/**`
- Additive Justfile recipe **only if** you must (prefer `planning/qa/` script)

## Forbidden

- Product skel, cosmic vendor, apps, duress, pins, handbook prose
- Do not merge other lanes onto main

## Requirements

- [ ] New `planning/qa/check-image.sh`:
      - Env `HYPRWAVE_IMAGE` default `localhost/hyprwave:latest`
      - If image missing → SKIP (not FAIL)
      - `podman run --rm --entrypoint bash "$img" -lc` asserts:
        assistant version, hyprwave-theme, walker, hyprpaper, 11 themes,
        catalog.toml, ENABLE.md, **no** `pam_duress` in `/etc/pam.d`,
        sddm enabled, no wofi/swaybg binaries as defaults
- [ ] Register in `run-all.sh` (after assistant). Document `--only image`
- [ ] Optional second image `HYPRWAVE_COSMIC_IMAGE` or `--cosmic` : cosmic-greeter,
      no sddm required, no cosmic-store, FlatArcade present — SKIP if missing
- [ ] Update ENDPOINT-RESIDUALS.md / PROGRAM-CLOSEOUT.md / SMOKE-MATRIX.md:
      CI run `31662742064` both variants PASS; GHCR anonymous still 403;
      local hyprland image inspected; VM smoke still open
- [ ] `bash planning/qa/run-all.sh` still RESULT OK (image check PASS or SKIP)

## Deliverables

- check-image.sh + run-all hook
- Residuals reflect T8 image-build **met**, VM **open**, GHCR public **open**

## Done criteria

- [ ] Harness RESULT OK
- [ ] Image check PASS against `localhost/hyprwave:latest` if present
- [ ] Residuals no longer say “all T8 pending”
- [ ] `git push -u origin lane/g-qa`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
