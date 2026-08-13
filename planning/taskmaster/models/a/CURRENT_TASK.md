# CURRENT_TASK

status: OPEN
task_id: A-W3-001
wave: 3
issued: 2026-08-13T03:35:03Z
poll: 2m
title: FIRST-BOOT-CHECKLIST mark local+CI image proofs; GHCR 403 still honest; pin HEAD re-verify

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

A-W2-002 added GHCR-VISIBILITY + safe action bumps. Wave 3: stamp
FIRST-BOOT-CHECKLIST with **local + CI** image proofs; keep anonymous GHCR
as **403**; re-verify pin HEAD.

Refresh first:

```bash
git fetch origin
git checkout lane/a-stabilize
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/a/
```

## Exclusive paths (only these)

- `build_files/versions.env`
- `build_files/build.sh` (pins / sourcing / checksum **only**)
- `.github/workflows/*`
- `planning/integration/a-stabilize/**`
- `planning/taskmaster/models/a/**`

## Forbidden

- Enabling duress PAM, handbook prose (B), assistant/duress product, skel
- Force-push main; do not invent floating `/releases/latest`
- Do not claim GHCR is public

## Requirements

- [ ] FIRST-BOOT-CHECKLIST: mark local `localhost/hyprwave:latest` +
      `localhost/hyprwave-cosmic:latest` inspects; CI run `31662742064`
      dual-image PASS; VM smoke still OPEN
- [ ] GHCR anonymous pull still documented as 403 (visibility card / RELEASE)
- [ ] `bash planning/integration/a-stabilize/scripts/verify-pins.sh --head --light`
- [ ] `bash planning/qa/run-all.sh --only pins-static` PASS
- [ ] Pin bump only if broken; else WORK_LOG “pins still current”

## Deliverables

- Checklist proofs stamped 2026-08-13
- Pin verify snippet in WORK_LOG
- COMPLETED line

## Done criteria

- [ ] No public-GHCR claim
- [ ] Pins still fail-closed
- [ ] pins-static PASS
- [ ] `git push -u origin lane/a-stabilize`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
