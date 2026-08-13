# CURRENT_TASK

status: DONE
task_id: A-W5-001
wave: 5
issued: 2026-08-13T03:50:00Z
poll: 2m
title: Post-merge pin verify on main (A Wave 2–4 landed)

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main`. Exclusive paths only.

## Objective

`lane/a-stabilize` Waves 2–4 are **merged to main**. Re-verify pins and
workflows on the merge tip. Do not invent new features.

```bash
git fetch origin
git checkout lane/a-stabilize
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/a/
```

## Exclusive paths (only these)

- `build_files/versions.env`
- `build_files/build.sh` (pins only)
- `.github/workflows/*`
- `planning/integration/a-stabilize/**`
- `planning/taskmaster/models/a/**`

## Forbidden

- Handbook, skel, duress, assistant
- Force-push; `/releases/latest`

## Requirements

- [x] `bash planning/qa/run-all.sh --only pins-static` PASS on merged main
- [x] Confirm `build.yml` action SHA bumps from A-W2-002 are on HEAD
- [x] GHCR still documented private
- [x] WORK_LOG: merge commit SHA

## Done criteria

- [x] pins-static PASS
- [x] `git push -u origin lane/a-stabilize`
