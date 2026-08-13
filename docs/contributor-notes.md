# Contributor notes (docs-friendly)

This page is for people editing the **Hyprwave image repo**. End users can ignore it
and use [INSTALL.md](../INSTALL.md) + [docs/README.md](README.md).

---

## What this repository is

Hyprwave is a **bootc image definition** (Universal Blue `image-template` fork), not an
application monorepo:

| Path | Role |
|------|------|
| `Containerfile` | Base image + multi-stage build |
| `build_files/build.sh` | Packages, services, skel deploy |
| `build_files/etc/skel/` | Defaults for **new** users only |
| `build_files/usr/share/hyprwave/` | Themes, wallpapers, helpers |
| `Justfile` | `just build`, ISO, VM |
| `docs/`, `INSTALL.md`, `CHANGELOG.md` | Operator handbook (Model B / `lane/b-docs`) |

Contributor depth: [CLAUDE.md](../CLAUDE.md), [AGENTS.md](../AGENTS.md).

---

## Parallel lanes (do not step on each other)

Work is split so models/branches do not edit the same product files. Canonical
protocol: **[planning/taskmaster/PROTOCOL.md](../planning/taskmaster/PROTOCOL.md)**.

| Model | Branch | Owns (typical) |
|-------|--------|----------------|
| A | `lane/a-stabilize` | pins (`versions.env`), CI guards, stabilize notes |
| **B** | **`lane/b-docs`** | **INSTALL, CHANGELOG, README, `docs/**`, `planning/integration/b-docs/**`** |
| C | `lane/c-assistant` | Assistant app (now **image-hooked** on main) |
| D | `lane/d-duress` | Duress packaging (**off by default**) |
| E | `lane/e-hyprland` | Hyprland skel / keybinds / session |
| F | `lane/f-cosmic` | COSMIC vendor / greeter / declutter |
| G | `lane/g-qa` | QA scripts, smoke matrix, merge playbook |

**Model B must not edit** `build_files/**` product code, workflows, apps, or duress
enablement. Read those trees only for **accuracy** (e.g. keybinds, package names).

If docs need a product fix, file it under
`planning/integration/b-docs/ISSUES.md` — do not “just fix” another lane’s files.

---

## Task Master (overnight / directed work)

Director issues tasks under `planning/taskmaster/models/<letter>/CURRENT_TASK.md`.

1. `git fetch origin main`
2. `git checkout origin/main -- planning/taskmaster/models/b/` (and PROTOCOL if needed)
3. Obey `status:` OPEN → IN_PROGRESS → DONE / BLOCKED
4. Work only exclusive paths; push `lane/b-docs`
5. When Done criteria are true: status DONE, append WORK_LOG + COMPLETED
6. **Idle** until a new OPEN task appears — do not invent unassigned work

Full rules: [PROTOCOL.md](../planning/taskmaster/PROTOCOL.md).  
Program board: `planning/taskmaster/STATUS.md` (on `main` after director check-ins).

---

## Refreshing the handbook after lane merges

**Canonical step-by-step:**  
[planning/integration/b-docs/POST-MERGE-DOC-FLIP.md](../planning/integration/b-docs/POST-MERGE-DOC-FLIP.md)

When the integrator lands A–G (or a subset) onto `main`, docs must **stop claiming
pending** for features that actually shipped. Summary:

1. **Diff product sources on the new `main` tip**
   - Keybinds: `build_files/etc/skel/.config/hypr/bindings.conf` vs [keybinds.md](keybinds.md)
   - Autostart / themes / greeters: `build.sh` case arms, `/usr/share/cosmic/`
   - Pins: `build_files/versions.env` if present
2. **Edit honesty language**
   - [CHANGELOG.md](../CHANGELOG.md): use the **Post-merge template** under Unreleased;
     add `## [YYYY-MM-DD]` and uncheck only what is truly on the image
   - Drop leftover “until merge” notes if any remain (E is on main)
   - Keep duress **off by default** even if D assets are on the image
   - Mention Assistant only if the binary is actually installed
3. **Re-run accuracy**
   - Relative link walk (see [ACCURACY-AUDIT.md](../planning/integration/b-docs/ACCURACY-AUDIT.md))
   - Grep removed stack: `Wofi|swaybg|Thunar` as defaults
   - Grep forbidden claims: GHCR public (unless verified), duress on by default
4. **Skel caveat** — image merge does not rewrite existing users’ `~/.config`; document
   when defaults change for **new** users only.
5. **Screenshots** — still optional; ops checklist in
   [screenshots.md](screenshots.md) / b-docs screenshot-checklist.

After Waves 1–4 landed on `main` (2026-08-13), prefer documenting **what is on
`main` / the built image** over lane-only language. **VM smoke is still open**;
GHCR remains private (403). Use
[POST-MERGE-DOC-FLIP.md](../planning/integration/b-docs/POST-MERGE-DOC-FLIP.md)
when a later wave lands.

---

## Doc accuracy rules

- Launcher is **Walker**, not Wofi.  
- Wallpaper daemon is **hyprpaper**, not swaybg.  
- File manager default is **Yazi**, not Thunar.  
- Do not claim GHCR is public without verification.  
- Do not claim duress is on by default.  
- Keybinds: read skel `bindings.conf`; note skel = **new users only**.  
- Architecture boundaries: Assistant is image-hooked; duress is packaged **off
  by default** — [architecture.md](architecture.md).  
- After doc edits, re-check relative links and update ACCURACY-AUDIT.

---

## Building and validating (contributors)

```bash
just lint          # shellcheck
just check         # Justfile format
just build hyprwave latest   # pass name: default IMAGE_NAME is image-template
just build-cosmic
# VM (sudo): just run-vm-qcow2
```

**`IMAGE_NAME`:** Justfile default is `image-template` (template heritage). CI uses
the repo name (`hyprwave`). Always pass `just build hyprwave latest` or
`IMAGE_NAME=hyprwave just build` in local docs/examples — **do not** edit the
Justfile only to rename the default (see ISSUES B-6, closed as docs note).

Docs-only changes do **not** require a full image build, but INSTALL recipe names must
match the Justfile.

---

## Skel caveat (docs and product)

Changing files under `build_files/etc/skel/` only affects **new** users after the next
image is built and installed. Document that clearly whenever you describe defaults.

---

## Related

- [architecture.md](architecture.md)  
- [security.md](security.md)  
- [CHANGELOG.md](../CHANGELOG.md) — Wave 1 integration section + history  
- [planning/integration/b-docs/](../planning/integration/b-docs/)  
- [PROTOCOL.md](../planning/taskmaster/PROTOCOL.md)  
