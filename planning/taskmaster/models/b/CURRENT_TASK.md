# CURRENT_TASK

status: OPEN  
task_id: B-W1-001  
wave: 1  
issued: 2026-08-07T03:50:00Z  
title: Ship a full operator handbook and accuracy audit  

## Objective

Produce a **handbook-quality** doc set so a new user and a contributor can install, update, troubleshoot, and understand Hyprland vs COSMIC without reading planning theory docs. Depth over speed.

## Exclusive paths

- `INSTALL.md`, `CHANGELOG.md`, `README.md`
- `docs/**`
- `planning/integration/b-docs/**`

## Forbidden

- Editing `build_files/**`
- Claiming duress is enabled by default
- Claiming GHCR is public unless verified
- Inventing keybinds not present in skel `bindings.conf` (read from main or describe as “typical”)

## Requirements

- [ ] `docs/README.md` index of all user docs
- [ ] Expand or create: troubleshooting, architecture, updating, security, cosmic, theming, keybinds (link `docs/keybinds.md` if exists)
- [ ] `docs/faq.md` — ≥12 real Q&As (bootc, skel caveat, themes, Walker, FlatArcade, dual DE, updates)
- [ ] `docs/contributor-notes.md` — how lanes work, where not to edit, link Task Master PROTOCOL
- [ ] INSTALL.md: Atomic rebase + ISO paths + private GHCR contingency + first hour after login
- [ ] CHANGELOG Unreleased section matches **lane reality** (Walker, themes, pins pending merge, assistant/duress as pending merge if not on main)
- [ ] Accuracy pass: grep docs for Wofi, swaybg, Thunar-as-default — remove/fix
- [ ] Screenshot checklist: every planned shot has purpose + alt text + capture command notes
- [ ] `planning/integration/b-docs/ACCURACY-AUDIT.md` listing sources checked (file paths)
- [ ] ≥3 commits; push `lane/b-docs`

## Deliverables

- Handbook under `docs/` + polished INSTALL/CHANGELOG/README
- ACCURACY-AUDIT.md

## Done criteria

- [ ] All Requirements met
- [ ] Relative links between docs resolve
- [ ] `git push -u origin lane/b-docs`
- [ ] WORK_LOG + COMPLETED; status DONE

## On completion

Set DONE, log, idle for next task.
