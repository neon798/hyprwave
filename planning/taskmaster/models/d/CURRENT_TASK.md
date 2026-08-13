# CURRENT_TASK

status: DONE
task_id: D-W2-001
wave: 2
issued: 2026-08-13T03:25:00Z
poll: 2m
title: Image-backed duress safety pass (stay OFF)

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

Image inspect of `localhost/hyprwave:latest` (2026-08-13): `pam_duress.so` and
`hyprwave-duress-setup` ship; **zero** `pam_duress` lines in `/etc/pam.d`; no
`*.sha256`. Harden packaging/docs/tests so that cannot regress.

Refresh first:

```bash
git fetch origin
git checkout lane/d-duress
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/d/
```

## Exclusive paths (only these)

- `build_files/duress/**`
- `build_files/build-duress.sh`
- `planning/integration/d-duress/**`
- `planning/taskmaster/models/d/**`

## Forbidden

- Enabling pam_duress in any default PAM file shipped by the image
- Pre-signing templates; skel; assistant; handbook; CI

## Requirements

- [x] `bash planning/integration/d-duress/validate.sh` PASS
- [x] `bash planning/qa/run-all.sh --only duress-safety` PASS
- [x] ENABLE.md / README / THREAT-MODEL paths match image layout
      (`/usr/share/hyprwave/duress`, `/etc/duress.d` empty + README)
- [x] Add or tighten a validate gate: shipped `pam.d` snippets must **not** be
      installed under `/etc/pam.d` by `build.sh` (snippet-selftest already
      exists — extend if a hole remains)
- [x] `hyprwave-duress-setup --help` / `--dry-run` text: operator-only, PAM off
- [x] WORK_LOG: record image inspect facts (module present, PAM inert)

## Deliverables

- validate.sh still green
- Docs/tests match built image
- Explicit “still OFF” residual in RESIDUALS.md if present

## Done criteria

- [x] No default PAM enablement introduced
- [x] No `*.sha256` added under templates
- [x] validate + duress-safety PASS
- [x] `git push -u origin lane/d-duress`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
