# Hyprwave Task Master System

**Director (Task Master):** issues work, reviews every **2 minutes**, advances toward the endpoint.  
**Models A–G:** independent workers; each polls **only its own** task files every **2 minutes**.

## Layout

```
planning/taskmaster/
  README.md                 # this file
  ENDPOINT.md               # definition of done for the whole program
  STATUS.md                 # live dashboard (Director updates)
  DIRECTOR_LOG.md           # Director check-in history
  PROTOCOL.md               # rules both sides must follow
  models/
    a/ … g/
      IDENTITY.md           # role, branch, exclusive paths
      CURRENT_TASK.md       # THE task file models poll (status: OPEN|IN_PROGRESS|DONE|BLOCKED)
      WORK_LOG.md           # model appends progress; Director reads
      COMPLETED.md          # archive of finished task_ids
```

## Model duty cycle (every 2 minutes)

1. `git pull` your lane branch (and optionally `git fetch origin` for `planning/taskmaster` if merged to main — **or** read task files from `origin/main` without merging product code).
2. Open `planning/taskmaster/models/<letter>/CURRENT_TASK.md`.
3. If `status: OPEN` → set `IN_PROGRESS`, do the work, commit on **your lane only**, push lane branch.
4. If `status: IN_PROGRESS` → continue until Done criteria met.
5. If Done criteria met → set `status: DONE`, append summary to `WORK_LOG.md` and `COMPLETED.md`, **stop and wait** for a new OPEN task.
6. If `status: DONE` or no new task → idle (do not invent work that crosses ownership).
7. If blocked → `status: BLOCKED` + reason in WORK_LOG (never edit another model’s paths).

**Important:** Task Master files live on `main` under `planning/taskmaster/`. Models should:

```bash
git fetch origin main
# read tasks without merging foreign product code:
git show origin/main:planning/taskmaster/models/a/CURRENT_TASK.md
# OR merge only the taskmaster tree if you know how; prefer worktree for product + pull main for tasks
```

Recommended: keep product work on `lane/*` and **periodically** `git checkout origin/main -- planning/taskmaster/models/<you>/` to refresh task files only.

## Director duty cycle (every 2 minutes)

**Do not** commit/push `main` on a quiet cycle (empty STATUS heartbeats starve CI).
Only push `main` when issuing/cancelling tasks or recording a real state change.

1. Read each `CURRENT_TASK.md` + latest `WORK_LOG.md`.
2. If DONE → verify deliverables exist on the lane branch; archive; issue **next** OPEN task.
3. If stuck/BLOCKED → unblock with narrower task or reassign scope (never steal files).
4. Update `STATUS.md` + append `DIRECTOR_LOG.md`.
5. Push `main` (taskmaster only) so models can fetch new tasks.

## Independence law

- No model waits on another model’s PR.
- No shared choke-point edits unless the task **explicitly** assigns that path to that model.
- Features that need `build.sh` ship as **snippets** under `planning/integration/<lane>/` unless Model A (or later Integrator task) owns the hook.
