# CURRENT_TASK

status: OPEN  
task_id: G-W1-001  
wave: 1  
issued: 2026-08-07T03:50:00Z  
title: QA harness + merge playbook for seven-lane integration  

## Objective

Build the **glue without merging**: scripts that validate packaging invariants across the repo, a merge order playbook for morning integration, and host-side checks that Director/humans can run. Deep automation — not a one-page checklist.

## Branch setup

```bash
git fetch origin
git checkout -B lane/g-qa origin/main
```

## Exclusive paths

- `planning/qa/**`
- `planning/integration/g-qa/**`

## Forbidden

- Implementing Assistant/Duress/desktop features
- Force-merging other lanes
- Editing exclusive paths of A–F product code

## Requirements

- [ ] `planning/qa/README.md` — how to run the harness
- [ ] `planning/qa/check-pins-static.sh` — grep no releases/latest; versions.env keys present (works even if A’s branch not merged — detect files if present)
- [ ] `planning/qa/check-themes.sh` — each theme under `build_files/usr/share/hyprwave/themes/*` has expected components (looknfeel, waybar style, walker style, ghostty, wallpaper or documented exception)
- [ ] `planning/qa/check-no-wofi-swaybg.sh` — fail if skel still references removed stack
- [ ] `planning/qa/check-duress-safety.sh` — if duress tree present: no *.sha256; call validate.sh if present
- [ ] `planning/qa/check-assistant.sh` — if apps/hyprwave-assistant present: `go test ./...`
- [ ] `planning/qa/run-all.sh` — runs all checks; non-zero on failure; prints summary table
- [ ] `planning/integration/g-qa/MERGE-PLAYBOOK.md` — exact order A→B→C→D→E→F→G, conflict hotspots (`build.sh`, README, Containerfile), snippet apply steps for C/D
- [ ] `planning/integration/g-qa/SMOKE-MATRIX.md` — Hyprland + COSMIC smoke matrix linking E/F session smokes when present
- [ ] ≥3 commits; push `lane/g-qa`
- [ ] `bash planning/qa/run-all.sh` runs on current tree (may soft-skip missing lane artifacts with WARN not silent pass)

## Deliverables

- QA harness + merge playbook + smoke matrix

## Done criteria

- [ ] Requirements met; run-all produces clear output; push; WORK_LOG + COMPLETED; status DONE

## On completion

Idle for next OPEN task.
