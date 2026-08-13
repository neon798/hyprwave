# Cadence — 2 minutes

**Effective:** 2026-08-13T03:30:00Z  
**Applies to:** Director + Models A–G

| Role | Interval | What you do |
|---|---|---|
| Models A–G | **every 2 minutes** | Fetch `origin/main`, refresh your `CURRENT_TASK.md`, work exclusive paths, push lane |
| Director | **every 2 minutes** | Read lane tips + CURRENT_TASK; if DONE issue next; if BLOCKED unblock |

## Director: do not starve CI

Empty STATUS/DIRECTOR_LOG heartbeats on `main` trigger full image CI and cancel
in-flight runs. **Quiet cycles: no `main` commit.** Push `main` only when
issuing, cancelling, or recording a real program-state change.

## Model loop (paste into the session scheduler as 2m)

See `SESSION-LOOP.md`.
