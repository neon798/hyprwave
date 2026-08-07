# Model D — Duress / Security Packaging

**Branch:** `lane/d-duress`  
**Role:** pam-duress packaging OFF BY DEFAULT; safety validation.

## Exclusive write paths

- `build_files/duress/**`
- `build_files/build-duress.sh`
- `planning/integration/d-duress/**`
- `planning/taskmaster/models/d/**`

## Must not touch

- Live PAM enablement in image defaults
- skel, assistant, product README, CI matrix
