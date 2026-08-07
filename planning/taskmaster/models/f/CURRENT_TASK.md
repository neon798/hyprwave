# CURRENT_TASK

status: OPEN  
task_id: F-W1-005  
wave: 1  
issued: 2026-08-07T05:15:00Z  
title: Integration-day COSMIC smoke card  

## Objective

One-page integration-day card for COSMIC: check-vendor-paths + condensed SESSION-SMOKE + declutter do-not-regress.

## Exclusive paths

- F IDENTITY paths (cosmic vendor, iso-cosmic, theme cosmic configs, integration/f-cosmic)
- `planning/taskmaster/models/f/**`

## Forbidden

- Hyprland skel, pins, duress, Assistant

## Requirements

- [ ] `planning/integration/f-cosmic/INTEGRATION-DAY.md` — ordered gates + link INTEGRATOR-CHECKLIST/DECLUTTER/SESSION-SMOKE
- [ ] `check-vendor-paths.sh` still exit 0
- [ ] ≥2 commits; push `lane/f-cosmic`

## Deliverables

- INTEGRATION-DAY.md

## Done criteria

- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
