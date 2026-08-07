# CURRENT_TASK

status: OPEN  
task_id: B-W1-005  
wave: 1  
issued: 2026-08-07T05:15:00Z  
title: Post-merge doc flip checklist (integrator-facing)  

## Objective

Provide a single checklist the integrator (or B after merge) uses to flip handbook language from “pending merge” to “on main” without inventing product facts.

## Exclusive paths

- `INSTALL.md`, `CHANGELOG.md`, `README.md`
- `docs/**`
- `planning/integration/b-docs/**`
- `planning/taskmaster/models/b/**`

## Forbidden

- Editing build_files
- Claiming GHCR public unless verified
- Claiming duress on by default

## Requirements

- [ ] `planning/integration/b-docs/POST-MERGE-DOC-FLIP.md` — exact files/sections to edit after A–G land; CHANGELOG Released subsection steps; honesty rules
- [ ] Optional stub section in CHANGELOG already points at this file
- [ ] ACCURACY-AUDIT note for post-merge pass
- [ ] ≥2 commits; push `lane/b-docs`

## Deliverables

- POST-MERGE-DOC-FLIP.md

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
