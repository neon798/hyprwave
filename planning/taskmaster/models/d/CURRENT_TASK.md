# CURRENT_TASK

status: OPEN  
task_id: D-W1-005  
wave: 1  
issued: 2026-08-07T05:15:00Z  
title: Integration-day duress gate card  

## Objective

One-page integration-day card: merge D → apply snippets → validate green → never enable PAM.

## Exclusive paths

- `build_files/duress/**`
- `build_files/build-duress.sh`
- `planning/integration/d-duress/**`
- `planning/taskmaster/models/d/**`

## Forbidden

- Enabling pam_duress by default
- Committing `*.sha256`
- Skel / assistant / handbook

## Requirements

- [ ] `planning/integration/d-duress/INTEGRATION-DAY.md` — short ordered gate linking INTEGRATOR-CHECKLIST, validate, snippet-selftest, SIGNING “do not commit”
- [ ] validate.sh + snippet-selftest still exit 0
- [ ] ≥2 commits; push `lane/d-duress`

## Deliverables

- INTEGRATION-DAY.md

## Done criteria

- [ ] validate green; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
