# CURRENT_TASK

status: OPEN  
task_id: D-W1-004  
wave: 1  
issued: 2026-08-07T05:05:00Z  
title: Pre-merge duress freeze + integrator checklist  

## Objective

Freeze duress packaging for merge: single INTEGRATOR-CHECKLIST, validate+snippet-selftest green, reaffirm OFF by default with no path to accidental enable.

## Exclusive paths

- `build_files/duress/**`
- `build_files/build-duress.sh`
- `planning/integration/d-duress/**`
- `planning/taskmaster/models/d/**`

## Forbidden

- Enabling pam_duress in defaults
- Committing `*.sha256`
- Skel / assistant / handbook product prose

## Requirements

- [ ] `planning/integration/d-duress/INTEGRATOR-CHECKLIST.md` — ordered steps: merge tree → apply snippets → do **not** enable PAM → run validate → document operator ENABLE path only
- [ ] README index links SIGNING, RESIDUALS, FAQ, OPERATOR-RUNBOOK, DRILL, checklist
- [ ] `validate.sh` + `snippet-selftest.sh` exit 0
- [ ] Confirm zero `*.sha256` in tree; no active pam.d writes in snippets
- [ ] ≥3 commits; push `lane/d-duress`

## Deliverables

- INTEGRATOR-CHECKLIST + freeze validation

## Done criteria

- [ ] validate + snippet-selftest green; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
