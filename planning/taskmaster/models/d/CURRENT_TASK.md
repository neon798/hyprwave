# CURRENT_TASK

status: OPEN  
task_id: D-W1-001  
wave: 1  
issued: 2026-08-07T03:50:00Z  
title: Security review pack + extra templates + validate expansion  

## Objective

Harden duress beyond Wave 2: formal threat model, more safe-by-default tooling, expanded automated guards, and operator drills — **without ever enabling PAM by default**.

## Exclusive paths

- `build_files/duress/**`
- `build_files/build-duress.sh`
- `planning/integration/d-duress/**`

## Forbidden

- Enabling pam_duress in shipped PAM configs
- Pre-signed `*.sha256` in repo
- Skel / assistant / README product docs
- “Quick” DONE without validate.sh green

## Requirements

- [ ] `build_files/duress/THREAT-MODEL.md` — assets, adversaries, residual risks, explicit non-goals (LUKS, forensics)
- [ ] New template `20-decoy-notice.sh` **or** `20-local-only-clear.sh` that only clears browser session caches under a single path — still mild/unsigned; document severity table update in README
- [ ] Setup tool: `--verify` mode that checks modes + presence of matching `.sha256` for scripts in target dir (read-only)
- [ ] `validate.sh` gains: forbids `required pam_duress` in any snippet that claims to be default; ensures THREAT-MODEL exists; ensures no `*.sha256`; runs `--verify` dry paths
- [ ] `planning/integration/d-duress/DRILL.md` — step-by-step disposable VM drill (30–45 min operator procedure)
- [ ] ENABLE.md: recovery if locked out; bootc upgrade PAM drift warning expanded with example commands
- [ ] build-duress.sh: print pin + date; optional `PAM_DURESS_COMMIT` env documented in BUMP-style comment block
- [ ] ≥3 commits; push `lane/d-duress`
- [ ] `bash planning/integration/d-duress/validate.sh` exits 0

## Deliverables

- Threat model, drill, verify mode, extra template, stronger validate

## Done criteria

- [ ] Requirements met; validate green; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
