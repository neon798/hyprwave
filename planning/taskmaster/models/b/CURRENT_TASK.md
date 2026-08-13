# CURRENT_TASK

status: DONE
task_id: B-W3-001
wave: 3
issued: 2026-08-13T03:31:08Z
completed: 2026-08-13T03:40:00Z
poll: 2m
title: first-boot.md + INSTALL: local just build path vs GHCR private; no screenshot binaries

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

B-W2-002 closed IMAGE_NAME / B-6. Wave 3: make **first-boot + INSTALL** tell
the truth about how to get an image today — local `just build` /
`localhost/hyprwave:latest` works; **anonymous GHCR is still 403**. Do not
add screenshot binaries.

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
- Committing screenshot binaries or fake `docs/assets/` images

## Requirements

- [x] `docs/first-boot.md` + `INSTALL.md`: primary path for a new operator
      includes local build (`just build` / IMAGE_NAME note already on main);
      GHCR pull is **authenticated or private** — do not write `podman pull`
      as if anonymous works
- [x] Dual-variant: hyprland vs cosmic first-boot greeter still accurate
      (SDDM vs cosmic-greeter)
- [x] B-7 screenshots remain TODO — no new PNG/JPG
- [x] Link walk 0 missing for files you touch
- [x] ACCURACY-AUDIT addendum for B-W3-001

## Deliverables

- Honest install/first-boot vs private GHCR + local images
- WORK_LOG + COMPLETED

## Done criteria

- [x] No anonymous-public GHCR claim
- [x] No screenshot binaries
- [x] Duress still off in any security sentence you touch
- [x] `git push -u origin lane/b-docs`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
