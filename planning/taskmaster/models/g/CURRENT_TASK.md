# CURRENT_TASK

status: DONE
task_id: G-W2-003
wave: 2
issued: 2026-08-13T03:25:30Z
poll: 2m
title: Wire check-image into CI snippet as continue-on-error / skip-ok

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

G-W2-001 landed `planning/qa/check-image.sh` (skip-if-missing) and hooked it
in `run-all.sh`. CI still uses the **copy-paste** snippet only. Add an
**advisory** image-inspect job so integrators can paste it without turning a
missing GH runner image into a red build.

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
- Do **not** edit `.github/workflows/*` (A owns live CI). Snippet only.
- Do not merge other lanes onto main

## Requirements

- [x] Extend `planning/qa/ci-snippet.yml` with a job (e.g. `packaging-qa-image`):
      - `continue-on-error: true` (advisory; never blocks the workflow)
      - Runs `bash planning/qa/run-all.sh --only image` (SKIP if no image/podman)
      - Document that GH-hosted runners will typically **SKIP** (no local tag)
      - Optional cosmic: `HYPRWAVE_COSMIC_IMAGE` / note `--cosmic` — still SKIP-ok
      - No secrets; do not require a GHCR pull
- [x] README: how to enable the job after a self-hosted / image-bearing runner exists
- [x] SMOKE-MATRIX or ENDPOINT-RESIDUALS: one line that snippet is advisory-only
- [x] `bash planning/qa/run-all.sh` still RESULT OK (do not change skip-if-missing)

## Deliverables

- ci-snippet.yml image job + README note
- Residual: live workflow still A's copy step (not done in this task)

## Done criteria

- [x] Snippet job is skip-ok / continue-on-error
- [x] No live workflow change
- [x] Harness RESULT OK
- [x] `git push -u origin lane/g-qa`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
