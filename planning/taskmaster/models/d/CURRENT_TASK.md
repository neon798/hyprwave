# CURRENT_TASK

status: DONE  
task_id: D-W1-002  
wave: 1  
issued: 2026-08-07T04:45:00Z  
title: Negative-path validate, operator FAQ, packaging dry-run proof  

## Objective

Harden duress packaging toward ENDPOINT residual confidence: automated **negative** tests, operator FAQ for enable/disable/recovery, and proof that stock image path remains PAM-off — still **never** enable PAM by default.

## Exclusive paths

- `build_files/duress/**`
- `build_files/build-duress.sh`
- `planning/integration/d-duress/**`
- `planning/taskmaster/models/d/**`

## Forbidden

- Enabling pam_duress in shipped PAM configs
- Pre-signed `*.sha256` in repo
- Skel / assistant / product README handbook (B)
- Marking DONE without validate.sh green

## Requirements

- [x] Expand `validate.sh` with **negative fixtures** (temp dirs): e.g. planted `*.sha256` must fail; snippet with `required pam_duress` must fail; missing THREAT-MODEL must fail — then clean up
- [x] `planning/integration/d-duress/FAQ.md` — ≥10 Q&As (what it is/isn’t, off by default, signing scripts, greeter/hyprlock, lockout recovery, bootc drift, residual risk vs LUKS)
- [x] `OPERATOR-RUNBOOK.md` — enable → test in disposable VM → disable/rollback ordered steps (link DRILL.md)
- [x] Audit all snippets: no path writes under `/etc/pam.d` in build hooks; document in WORK_LOG
- [x] Optional mild template or setup flag only if justified; keep severity table accurate
- [x] Confirm `build-duress.sh` still prints pin+date; pin format full SHA
- [x] ≥3 commits; push `lane/d-duress`
- [x] `bash planning/integration/d-duress/validate.sh` exits 0

## Deliverables

- Stronger validate negatives, FAQ, operator runbook

## Done criteria

- [x] Requirements met; validate green; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
