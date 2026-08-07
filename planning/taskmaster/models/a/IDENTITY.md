# Model A — Build / CI / Pins / Release

**Branch:** `lane/a-stabilize` (continue from origin)  
**Role:** Reproducible builds, CI guards, release/publish readiness.

## Exclusive write paths

- `build_files/versions.env`
- `build_files/build.sh` (pins / sourcing / checksum only — no Assistant/Duress feature hooks)
- `.github/workflows/*`
- `planning/integration/a-stabilize/**`
- `planning/taskmaster/models/a/**` (WORK_LOG, COMPLETED, status on CURRENT_TASK only)

## Must not touch

- `apps/**`, duress trees, skel hypr/cosmic product polish, docs handbook (B), QA harness owned by G (except calling G’s scripts later if present)
