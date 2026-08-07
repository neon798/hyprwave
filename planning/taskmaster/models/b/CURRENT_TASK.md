# CURRENT_TASK

status: DONE  
task_id: B-W1-004  
wave: 1  
issued: 2026-08-07T05:05:00Z  
title: Pre-merge handbook freeze + post-merge CHANGELOG template  

## Objective

Freeze user docs for integration: honest pending-merge table final pass, CHANGELOG template ready for integrator after serial merge, architecture note covering Assistant + duress as optional/pending image features.

## Exclusive paths

- `INSTALL.md`, `CHANGELOG.md`, `README.md`
- `docs/**`
- `planning/integration/b-docs/**`
- `planning/taskmaster/models/b/**`

## Forbidden

- Editing `build_files/**`
- Claiming features on main that only exist on lanes
- Enabling or implying duress on by default

## Requirements

- [x] CHANGELOG Unreleased: final A–G pending-merge honesty table; add “Post-merge template” subsection with bullets integrator can flip to Released
- [x] `docs/architecture.md`: bootc + dual DE + theme store + (lane) Assistant/duress packaging boundaries
- [x] `docs/contributor-notes.md`: how to refresh handbook after lane merges; link Task Master PROTOCOL
- [x] Relative link check clean; ACCURACY-AUDIT freeze note (date + main tip)
- [x] ≥3 commits; push `lane/b-docs`

## Deliverables

- Handbook freeze docs + CHANGELOG post-merge template

## Done criteria

- [x] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
