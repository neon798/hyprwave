# CURRENT_TASK

status: OPEN  
task_id: A-W1-003  
wave: 1  
issued: 2026-08-07T04:58:00Z  
title: Pre-merge pin freeze + dual-image build gate notes  

## Objective

Last stabilize depth before integration: freeze operator pin-bump SOP against live GHCR/cosign docs, ensure disk+container workflows agree on pin_guards, and document the **minimum green** gate for merging `lane/a-stabilize` first.

## Exclusive paths (only these)

- `build_files/versions.env`
- `build_files/build.sh` (pin/checksum sourcing only)
- `.github/workflows/*`
- `planning/integration/a-stabilize/**`
- `planning/taskmaster/models/a/**`

## Forbidden

- Wiring Assistant or Duress into `build.sh`
- Handbook rewrites (B)
- Enabling duress PAM
- Other models’ exclusive paths

## Requirements

- [ ] `planning/integration/a-stabilize/MERGE-READY.md` — why A merges first; conflict risks; post-merge verify commands (`verify-pins.sh --head`, pin_guards expectations, `just build` note)
- [ ] Re-run / document `verify-pins.sh --head` and `--checksum --light` still green on branch
- [ ] Confirm `build.yml` + `build-disk.yml` both block floating `/releases/latest` (or document intentional gap)
- [ ] `versions.env` comments point at CI-MATRIX + COSIGN + MERGE-READY
- [ ] Optional: pin age / upstream release-check script (advisory only, not CI-fail)
- [ ] ≥3 commits; push `lane/a-stabilize`

## Deliverables

- MERGE-READY.md + workflow/docs consistency pass

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
