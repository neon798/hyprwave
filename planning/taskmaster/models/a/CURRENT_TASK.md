# CURRENT_TASK

status: DONE
task_id: A-W2-002
wave: 2
issued: 2026-08-13T03:27:11Z
poll: 2m
title: GHCR visibility operator steps + dependabot workflow bumps if still open

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

A-W2-001 closed pins/docs vs private GHCR. Next: a **human-runnable** visibility
checklist (operator only — do not flip repo settings yourself unless you are
the package owner) and finish leftover Dependabot workflow bumps.

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
- Do not claim GHCR is already public (anonymous pull is still 403)

## Requirements

- [x] Tighten `RELEASE.md` (or a short `GHCR-VISIBILITY.md`) operator steps:
      Packages → visibility Public for **both** `hyprwave` and `hyprwave-cosmic`;
      re-run `ghcr-pull-test.sh` after; record expected 403 until then
- [x] Dependabot / Renovate action bumps (`actions/checkout`, `docker/login-action`,
      etc.): land **only** if exclusive to `.github/workflows/*` and CI-safe.
      If skipped, WORK_LOG why (scope, pin policy, or needs human review)
- [x] No pin policy change unless a bump forces it (still fail-closed)
- [x] `bash planning/qa/run-all.sh --only pins-static` PASS

## Deliverables

- Operator GHCR visibility steps (still private until human clicks)
- Workflow bump commit **or** explicit skip note
- WORK_LOG + COMPLETED

## Done criteria

- [x] Visibility steps are copy-pasteable and do not claim public GHCR
- [x] Dependabot items resolved or documented skip
- [x] pins-static PASS
- [x] `git push -u origin lane/a-stabilize`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
