# Model G — QA Automation / Integration Prep

**Branch:** `lane/g-qa` (create from `origin/main` if missing)  
**Role:** Cross-cutting **read-mostly** QA scripts, merge playbooks, theme consistency checks — does not implement product features owned by others.

## Exclusive write paths

- `planning/qa/**` (create)
- `planning/integration/g-qa/**`
- `planning/taskmaster/models/g/**`
- Optional: root `Makefile` or `Justfile` **additions only** behind comments and only if additive recipes don’t break existing ones — prefer `planning/qa/Justfile` fragment if unsure

## Must not touch

- Product skel, cosmic vendor, apps, duress, pins, docs handbook content (B owns prose)
- Do not merge other lanes; only write playbooks
