# CURRENT_TASK

status: DONE  
task_id: A-W1-002  
wave: 1  
issued: 2026-08-07T04:45:00Z  
title: Dual-image CI matrix, cosign verify runbook, GHCR visibility path  

## Objective

Close remaining **release/reproducibility** gaps from ENDPOINT: dual Hyprland+COSMIC build matrix hygiene, operator cosign verification, and a concrete GHCR public/private contingency that does not leave `:latest` floating downloads.

## Exclusive paths (only these)

- `build_files/versions.env`
- `build_files/build.sh` (pin/checksum sourcing only)
- `.github/workflows/*`
- `planning/integration/a-stabilize/**`
- `planning/taskmaster/models/a/**` (WORK_LOG, COMPLETED, CURRENT_TASK status only)

## Forbidden

- Wiring Assistant or Duress into `build.sh`
- Rewriting README/INSTALL (Model B)
- Enabling duress PAM
- Editing other models’ exclusive paths

## Requirements

- [x] Audit `.github/workflows/build*.yml` for both image names (`hyprwave` / `hyprwave-cosmic` or DE matrix); document gaps in `planning/integration/a-stabilize/CI-MATRIX.md`
- [x] Add or tighten workflow so pin_guards (or equivalent) still runs on PRs; note any disk-image workflow that should depend on pins
- [x] `planning/integration/a-stabilize/COSIGN.md` — verify signed image steps (cosign verify with `cosign.pub`), failure modes, key rotation notes (no private keys)
- [x] Expand `RELEASE.md`: GHCR package visibility fix path (Settings → packages), anonymous pull test command, private-registry install contingency already hinted in FIRST-BOOT
- [x] Confirm zero `releases/latest` still holds; `verify-pins.sh --head` exit 0
- [x] Optional: small `scripts/ghcr-pull-test.sh` that attempts anonymous pull and exits non-zero with clear message (no secrets)
- [x] ≥3 commits on `lane/a-stabilize`; push origin

## Deliverables

- CI-MATRIX.md + COSIGN.md (+ optional ghcr-pull-test.sh)
- RELEASE.md updates for GHCR visibility
- Workflow fixes only if needed for dual-image / pin gates

## Done criteria

- [x] All Requirements satisfied
- [x] `bash planning/integration/a-stabilize/scripts/verify-pins.sh --head` documented as still green
- [x] `git push origin lane/a-stabilize`
- [x] WORK_LOG + COMPLETED updated; status DONE

## On completion

1. Set `status: DONE`  
2. Append WORK_LOG.md  
3. Append COMPLETED.md  
4. Idle until Task Master issues next OPEN task  
