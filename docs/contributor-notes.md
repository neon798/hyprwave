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
| `docs/`, `INSTALL.md` | Operator handbook (this lane) |

Contributor depth: [CLAUDE.md](../CLAUDE.md), [AGENTS.md](../AGENTS.md).

---

## Parallel lanes (do not step on each other)

Work is split so models/branches do not edit the same product files. Canonical
protocol: [planning/taskmaster/PROTOCOL.md](../planning/taskmaster/PROTOCOL.md).

| Model | Branch | Owns (typical) |
|-------|--------|----------------|
| A | `lane/a-stabilize` | pins (`versions.env`), CI guards, stabilize notes |
| **B** | **`lane/b-docs`** | **INSTALL, CHANGELOG, README, `docs/**`, b-docs integration** |
| C | `lane/c-assistant` | Assistant app + dormant snippets |
| D | `lane/d-duress` | Duress packaging (**off by default**) |
| E–G | other lanes | DE polish / QA (see Task Master STATUS) |

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

---

## Doc accuracy rules

- Launcher is **Walker**, not Wofi.  
- Wallpaper daemon is **hyprpaper**, not swaybg.  
- File manager default is **Yazi**, not Thunar.  
- Do not claim GHCR is public without verification.  
- Do not claim duress is on by default.  
- Keybinds: read `build_files/etc/skel/.config/hypr/bindings.conf` (or document as
  skel defaults for new users only).  
- After doc edits, re-check relative links and run the accuracy grep (see
  [ACCURACY-AUDIT.md](../planning/integration/b-docs/ACCURACY-AUDIT.md)).

---

## Building and validating (contributors)

```bash
just lint          # shellcheck
just check         # Justfile format
just build hyprwave latest
just build-cosmic
# VM (sudo): just run-vm-qcow2
```

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
- [planning/integration/b-docs/](../planning/integration/b-docs/)  
