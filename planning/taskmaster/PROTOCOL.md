# Protocol

## Task file format (`CURRENT_TASK.md`)

```markdown
# CURRENT_TASK

status: OPEN
task_id: X-W1-001
wave: 1
issued: 2026-08-07T00:00:00Z
title: Short title

## Objective
…

## Exclusive paths (only these)
…

## Forbidden
…

## Requirements
- [ ] …

## Deliverables
- …

## Done criteria
- [ ] …
- [ ] `git push -u origin <branch>`

## On completion
1. Set status: DONE
2. Append WORK_LOG.md with task_id, commits, notes
3. Append COMPLETED.md one-liner
4. Do not start unassigned work
```

## Status values

| status | Who sets | Meaning |
|---|---|---|
| OPEN | Director | Model must pick up |
| IN_PROGRESS | Model | Actively working |
| DONE | Model | Awaiting Director verification + next task |
| BLOCKED | Model | Cannot proceed; Director must act |
| CANCELLED | Director | Superseded |

## Branch naming

| Model | Branch |
|---|---|
| A | `lane/a-stabilize` |
| B | `lane/b-docs` |
| C | `lane/c-assistant` |
| D | `lane/d-duress` |
| E | `lane/e-hyprland` |
| F | `lane/f-cosmic` |
| G | `lane/g-qa` |

## Commits

- Small, frequent commits with clear messages.
- Push lane branch at least when marking DONE (preferably every 10 min if you have commits).

## Never

- Force-push `main`.
- Edit another model’s exclusive paths.
- Enable duress PAM by default.
- Mark DONE without Done criteria satisfied.
