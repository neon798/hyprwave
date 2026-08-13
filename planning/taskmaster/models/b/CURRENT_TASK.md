# CURRENT_TASK

status: OPEN
task_id: B-W4-001
wave: 4
issued: 2026-08-13T03:39:11Z
poll: 2m
title: CHANGELOG / ISSUES: record W2–W3 handbook deltas; no GHCR-public claim

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

Wave 4 is **merge-prep**. Record handbook deltas from W2–W3 (Assistant
keybind, IMAGE_NAME, local-build vs private GHCR) in CHANGELOG / ISSUES.
No screenshot binaries. No public-GHCR claim.

Refresh first:

```bash
git fetch origin
git checkout lane/b-docs
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/b/
```

## Exclusive paths (only these)

- `INSTALL.md`, `CHANGELOG.md`, `README.md`
- `docs/**`
- `planning/integration/b-docs/**`
- `planning/taskmaster/models/b/**`

## Forbidden

- `build_files/**`, workflows, apps, duress packaging, Justfile
- Claiming GHCR is public; claiming duress is on by default
- Screenshot binaries
- Merging this lane onto main

## Requirements

- [ ] CHANGELOG: Wave 2–3 handbook bullets (Super+Shift+A, IMAGE_NAME,
      local `just build` primary / GHCR 403)
- [ ] ISSUES.md: B-5/B-6 closed state accurate; B-7 screenshots still TODO
- [ ] No anonymous-public GHCR sentence
- [ ] Link walk 0 missing for files you touch

## Deliverables

- CHANGELOG + ISSUES merge-prep
- ACCURACY-AUDIT one-liner if needed
- WORK_LOG + COMPLETED

## Done criteria

- [ ] Deltas recorded; GHCR still private
- [ ] No screenshot binaries
- [ ] `git push -u origin lane/b-docs`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
