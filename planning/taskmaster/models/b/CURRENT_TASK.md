# CURRENT_TASK

status: DONE
task_id: B-W2-001
wave: 2
issued: 2026-08-13T03:25:00Z
completed: 2026-08-13T04:10:00Z
poll: 2m
title: Handbook residual polish after post-merge flip

## Duty cycle

Poll **every 2 minutes**. Fetch `origin/main` and refresh this file. Push lane
commits as you go. Do not idle on HOLD — HOLD is cancelled.

## Objective

Integrator already flipped most “pending merge” language (`70e5616`). Finish
the user-facing handbook so a new user can run the **shipped** desktop without
lane folklore.

## Exclusive paths (only these)

- `INSTALL.md`, `CHANGELOG.md`, `README.md`
- `docs/**`
- `planning/integration/b-docs/**`
- `planning/taskmaster/models/b/**`

## Forbidden

- `build_files/**`, workflows, apps, duress packaging
- Claiming GHCR is public; claiming duress is on by default

## Requirements

- [x] Add **Hyprwave Assistant** to README companion table (ships in image;
      Super+Shift+A on Hyprland; optional)
- [x] Document Super+Shift+A on [docs/keybinds.md](../../../docs/keybinds.md)
      Essentials table (missing today)
- [x] Close or rewrite ISSUES.md **B-5** (Assistant/Duress are on main:
      assistant hooked; duress packaged OFF)
- [x] Sweep `docs/` + `INSTALL.md` + `planning/integration/b-docs/` for leftover
      “pending merge / until merge / on lane” that is now false
- [x] README COSMIC dock line already updated — confirm it matches
      `build_files/usr/share/cosmic/.../favorites`
- [x] Keep screenshot binaries TODO (B-7); do not invent captures
- [x] Re-run POST-MERGE link walk (0 missing)

## Deliverables

- Handbook matches skel + CHANGELOG Wave 1 section
- ISSUES.md updated
- ACCURACY-AUDIT addendum for B-W2-001

## Done criteria

- [x] Super+Shift+A documented
- [x] Assistant listed as shipped (not “upcoming”)
- [x] Duress still **off by default** in security/faq
- [x] Link check 0 missing
- [x] `git push -u origin lane/b-docs`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
