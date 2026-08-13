# CURRENT_TASK

status: OPEN
task_id: B-W2-001
wave: 2
issued: 2026-08-13T03:25:00Z
title: Handbook residual polish after post-merge flip

## Objective

Integrator already flipped most “pending merge” language (`70e5616`). Finish
the user-facing handbook so a new user can run the **shipped** desktop without
lane folklore.

Refresh first:

```bash
git fetch origin
git checkout lane/b-docs
git merge --ff-only origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/b/
```

## Exclusive paths (only these)

- `INSTALL.md`, `CHANGELOG.md`, `README.md`
- `docs/**`
- `planning/integration/b-docs/**`
- `planning/taskmaster/models/b/**`

## Forbidden

- `build_files/**`, workflows, apps, duress packaging
- Claiming GHCR is public; claiming duress is on by default

## Requirements

- [ ] Add **Hyprwave Assistant** to README companion table (ships in image;
      Super+Shift+A on Hyprland; optional)
- [ ] Document Super+Shift+A on [docs/keybinds.md](../../../docs/keybinds.md)
      Essentials table (missing today)
- [ ] Close or rewrite ISSUES.md **B-5** (Assistant/Duress are on main:
      assistant hooked; duress packaged OFF)
- [ ] Sweep `docs/` + `INSTALL.md` + `planning/integration/b-docs/` for leftover
      “pending merge / until merge / on lane” that is now false
- [ ] README COSMIC dock line already updated — confirm it matches
      `build_files/usr/share/cosmic/.../favorites`
- [ ] Keep screenshot binaries TODO (B-7); do not invent captures
- [ ] Re-run POST-MERGE link walk (0 missing)

## Deliverables

- Handbook matches skel + CHANGELOG Wave 1 section
- ISSUES.md updated
- ACCURACY-AUDIT addendum for B-W2-001

## Done criteria

- [ ] Super+Shift+A documented
- [ ] Assistant listed as shipped (not “upcoming”)
- [ ] Duress still **off by default** in security/faq
- [ ] Link check 0 missing
- [ ] `git push -u origin lane/b-docs`

## On completion

1. Set status: DONE
2. Append WORK_LOG.md + COMPLETED.md
3. Do not start unassigned work
