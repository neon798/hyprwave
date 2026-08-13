# CURRENT_TASK

status: DONE
task_id: B-W2-002
wave: 2
issued: 2026-08-13T03:27:11Z
completed: 2026-08-13T03:35:00Z
poll: 2m
title: Justfile IMAGE_NAME note (B-6) + screenshot checklist remaining rows only

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

B-W2-001 shipped Assistant + Super+Shift+A. Close ISSUES **B-6** in **docs
only**: local `just build` defaults `IMAGE_NAME=image-template`; CI sets the
repo name (`hyprwave`). Keep screenshot binaries TODO (B-7) — polish checklist
rows, do not invent captures.

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

- `build_files/**`, workflows, apps, duress packaging, **Justfile** (document
  IMAGE_NAME — do not edit the Justfile)
- Claiming GHCR is public; claiming duress is on by default
- Committing screenshot binaries or fake `docs/assets/` images

## Requirements

- [x] INSTALL.md (and contributor-notes if needed): `IMAGE_NAME` default is
      `image-template`; override `IMAGE_NAME=hyprwave` / CI uses repo name
- [x] Close or rewrite ISSUES.md **B-6** after the note exists
- [x] screenshot-checklist.md: remaining TODO rows only — fix stale paths,
      blockers, or Hyprland vs COSMIC capture notes; leave Status TODO
- [x] Do not capture or embed new PNG/JPG
- [x] Link walk still 0 missing for files you touch

## Deliverables

- B-6 closed in ISSUES + INSTALL note
- Checklist hygiene only (B-7 still open)
- ACCURACY-AUDIT addendum for B-W2-002

## Done criteria

- [x] IMAGE_NAME default documented; Justfile untouched
- [x] No new screenshot binaries
- [x] Duress still off / GHCR not claimed public
- [x] `git push -u origin lane/b-docs`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
