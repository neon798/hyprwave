# CURRENT_TASK

status: OPEN  
task_id: D-W1-003  
wave: 1  
issued: 2026-08-07T04:55:00Z  
title: Signing workflow dry-run docs + snippet self-test + residual operator duties  

## Objective

Final packaging confidence before integration: document **how operators sign** without shipping signatures, prove snippets are inert, and list residual risks operators still own (ENDPOINT: packaged OFF by default).

## Exclusive paths

- `build_files/duress/**`
- `build_files/build-duress.sh`
- `planning/integration/d-duress/**`
- `planning/taskmaster/models/d/**`

## Forbidden

- Enabling pam_duress in shipped defaults
- Committing `*.sha256` signatures into the repo
- Skel / assistant / handbook prose (B)

## Requirements

- [ ] `planning/integration/d-duress/SIGNING.md` — generate checksums locally, install to target dir, `--verify` success path, **never** commit signatures; worked example with disposable path
- [ ] `snippet-selftest.sh` (or validate.sh section): asserts `build.sh.snippet` / `Containerfile.snippet` do not enable PAM / write pam.d; exit 0 on current tree
- [ ] README severity table still matches all templates; link FAQ + OPERATOR-RUNBOOK + SIGNING
- [ ] `RESIDUALS.md` — what packaging does **not** solve (disk encryption, physical access, signed-script trust root, bootc PAM drift) for integrator/B
- [ ] validate.sh still green including negatives
- [ ] ≥3 commits; push `lane/d-duress`

## Deliverables

- SIGNING.md, residuals, snippet self-test, README index polish

## Done criteria

- [ ] `bash planning/integration/d-duress/validate.sh` exits 0
- [ ] Requirements met; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
