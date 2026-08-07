# CURRENT_TASK

status: DONE  
task_id: A-W1-001  
wave: 1  
issued: 2026-08-07T03:50:00Z  
title: Deepen pin verification, CI fail-gates, and release automation docs  

## Objective

Make external binary pins **CI-enforced** and **operator-bumpable**, with a release/publish path that a human can follow without guessing. This is multi-hour depth — not a drive-by edit.

## Exclusive paths (only these)

- `build_files/versions.env`
- `build_files/build.sh` (pin/checksum sourcing only)
- `.github/workflows/*`
- `planning/integration/a-stabilize/**`

## Forbidden

- Wiring Assistant or Duress into `build.sh`
- Rewriting README/INSTALL (Model B)
- Enabling duress PAM
- Marking DONE under 30 minutes of real work unless all Done criteria are truly met

## Requirements

- [x] `build.sh` sources `versions.env` and verifies sha256 for Yazi, Neonwolf, FlatArcade (fail closed on mismatch)
- [x] Zero matches for `releases/latest` in `build_files/build.sh`
- [x] Script `planning/integration/a-stabilize/scripts/verify-pins.sh` downloads (or curl -I + sha256 if full download too heavy) and validates pins; documented usage
- [x] CI workflow step fails PRs if `releases/latest` reappears or if `verify-pins.sh` fails (where network allowed) OR a static job that at least greps + bash -n + checks versions.env keys exist
- [x] `planning/integration/a-stabilize/RELEASE.md` covers: version tags, GHCR package visibility, cosign, when to bump pins, rollback
- [x] `FIRST-BOOT-CHECKLIST.md` includes a fill-in log template (date, image digest, pass/fail per item)
- [x] `BUMP.md` includes a worked example of bumping one component end-to-end
- [x] At least **3 commits** on `lane/a-stabilize` for this task (incremental)
- [x] Branch pushed to origin

## Deliverables

- Updated pin pipeline + CI guards
- verify-pins.sh + docs under `planning/integration/a-stabilize/`
- RELEASE.md + expanded checklist

## Done criteria

- [x] All Requirements checkboxes satisfied
- [x] `bash planning/integration/a-stabilize/scripts/verify-pins.sh` documented; script exits 0 or clear skip reason
- [x] `git push -u origin lane/a-stabilize`
- [x] WORK_LOG + COMPLETED updated; status DONE

## On completion

1. Set `status: DONE`  
2. Append WORK_LOG.md  
3. Append COMPLETED.md  
4. Idle until Task Master issues next OPEN task  
