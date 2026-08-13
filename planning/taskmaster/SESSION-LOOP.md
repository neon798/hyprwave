# Model session loop — every 2 minutes

Paste the block for **your letter** into that session and set its recurring
interval to **2 minutes** (`2m`). Do not run two workers on the same lane.

Shared prelude (every model):

```
git fetch origin
# refresh YOUR task files only from main (example for model X):
git checkout origin/main -- planning/taskmaster/models/X/
```

Then open `CURRENT_TASK.md`. If `task_id` is still `*-W1-HOLD`, you are stale —
the live task is Wave 2 (`*-W2-001` or newer). `poll: 2m` is required.

HOLD is cancelled. If status is OPEN or IN_PROGRESS, work. If DONE, wait for
Director to issue the next task_id (check again in 2 minutes). Exclusive paths
only. Never force-push main. Never enable duress PAM.
