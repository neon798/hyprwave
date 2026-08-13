# CURRENT_TASK

status: OPEN
task_id: A-W2-001
wave: 2
issued: 2026-08-13T03:25:00Z
title: Pin verify + release closeout after Wave 1 CI

## Objective

Wave 1 is on `main`. CI built **and pushed** both variants on `77755f1`
(run `31662742064`). GHCR remains **anonymously private** (403). Make pins
and release docs match that reality so a human can ship a stable image.

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

## Requirements

- [ ] `bash planning/integration/a-stabilize/scripts/verify-pins.sh --head --light` (and `--checksum` if practical)
- [ ] If a pin is broken or a newer **compatible** companion release is clearly better, bump `versions.env` with SHA256 + comment (date, why)
- [ ] Update `RELEASE.md` / `FIRST-BOOT-CHECKLIST.md` / `COSIGN.md` as needed:
      CI dual-image success 2026-08-13; local `localhost/hyprwave:latest` exists;
      **do not** claim anonymous GHCR public
- [ ] Record GHCR visibility next step (repo package visibility / org settings) — operator notes only
- [ ] Dependabot branches (`actions/checkout-7`, `docker/login-action`, etc.):
      review; land **only** if the bump is exclusive to workflows and CI-safe.
      Leave a WORK_LOG note if you skip.

## Deliverables

- Pin verify log snippet in WORK_LOG
- Release/first-boot docs accurate vs merged main
- Optional pin bump commit **or** explicit “pins still current” note

## Done criteria

- [ ] Pins still fail-closed (no `/releases/latest`)
- [ ] `bash planning/qa/run-all.sh --only pins-static` PASS
- [ ] Docs in a-stabilize do not claim public GHCR
- [ ] `git push -u origin lane/a-stabilize`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
