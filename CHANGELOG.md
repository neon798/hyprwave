# Changelog

All notable user-facing changes to Hyprwave are documented here.
Format inspired by [Keep a Changelog](https://keepachangelog.com/).

Hyprwave ships as bootable container images
(`ghcr.io/neon798/hyprwave`, `ghcr.io/neon798/hyprwave-cosmic`). Tags and git history
matter more than classic tarball semver.

---

## [Unreleased]

### Status (honest merge state)

Desktop features below describe the **product on `main` at base `8a623a2`** plus work
finished on **parallel Wave-1 lanes**. Lane deliverables are **pending merge to
`main` / published GHCR `:latest`** until the integrator lands them. Do **not** treat
this Unreleased section as “already on the public image.”

Docs on `lane/b-docs` (INSTALL, `docs/**`, this file) track that reality for
onboarding without requiring readers to open `planning/`.

### Desktop — Hyprland (default image; base on main)

- **Hyprland** with split skel (`hyprland.conf` sources envs, monitors, input,
  looknfeel, bindings, autostart, windowrules).
- **Walker** + **elephant** plugins (apps, calc, runner, menus, websearch, files,
  providerlist). **Not Wofi.**
- **hyprpaper** wallpapers. **Not swaybg.**
- **Waybar**, **Mako**, **hypridle** / **hyprlock**, **hyprpicker**, **hyprsunset**,
  **hyprland-qtutils** (source-built in container builder stage).
- **SDDM** + custom synthwave QML theme.
- Keybinds (base): Super+D/Space (Walker), Super+R (runner), Super+Shift+T (themes),
  Super+Return/T (Ghostty), Super+E (Yazi), Super+B (Neonwolf), Super+A (FlatArcade).
  Handbook map prefers E-lane refinements when present — [docs/keybinds.md](docs/keybinds.md).

### Desktop — COSMIC (`hyprwave-cosmic`; base on main)

- `DE=cosmic` → `ghcr.io/neon798/hyprwave-cosmic:latest`.
- Fedora `@cosmic-desktop-environment` + **cosmic-greeter** (no SDDM / Hyprland stack).
- Vendor `/usr/share/cosmic/` defaults: palette, wallpaper, dock favorites.
- **cosmic-store** removed in favor of FlatArcade; other declutter as in README.
- User-facing summary: [docs/cosmic.md](docs/cosmic.md).

### Themes

- **11 packs** under `/usr/share/hyprwave/themes/`: `hyprwave` (default),
  `retro-arcade`, `cozy-harvest`, `fjord-dark`, `touge-drive`, `vaporwave`,
  `highway-haze`, `lunar-pulse`, `glitch-horizon`, `arcade-rain`, `verdant-haven`.
- **`hyprwave-theme`** CLI + **Hyprwave Themes** GUI (`hyprwave-theme-gui`,
  Super+Shift+T on Hyprland).
- Hyprland live-reloads UI chrome; COSMIC applies appearance keys + wallpaper.

### Companion applications (both variants)

- **Neonwolf** — browser; AppImage extracted at build to `/usr/lib/neonwolf/`.
- **FlatArcade** — Flathub TUI app store.
- **Yazi** — default file manager (terminal).
- **Ghostty** — default terminal.

### Platform

- Base: Universal Blue **`ghcr.io/ublue-os/base-main`**.
- `just build` / `build-cosmic` / `build-iso` / `build-iso-cosmic` / VM recipes.
- CI matrix: hyprland + cosmic; Cosign sign on push to `main` (PRs build only).
- Install / update docs: [INSTALL.md](INSTALL.md), [docs/updating.md](docs/updating.md).

### Documentation (this lane — `lane/b-docs`)

- [INSTALL.md](INSTALL.md) — dual-variant decision tree; ISO vs rebase; private GHCR.
- [docs/first-boot.md](docs/first-boot.md) — login → desktop → apps → themes → updates.
- [docs/keybinds.md](docs/keybinds.md) — reconciled to E KEYBIND-MAP / dwindle binds.
- [docs/README.md](docs/README.md) — handbook index.
- Operator pages: troubleshooting, architecture, updating, security, cosmic, theming,
  [faq.md](docs/faq.md), [contributor-notes.md](docs/contributor-notes.md).
- [ACCURACY-AUDIT.md](planning/integration/b-docs/ACCURACY-AUDIT.md) — sources checked.
- Screenshot checklist: purpose + alt text + capture notes (binaries still TODO).

### Wave-1 lane deliverables (**pending merge** — not claimed on main GHCR)

| Lane | Branch | Deliverable (summary) | Docs stance |
|------|--------|----------------------|-------------|
| A | `lane/a-stabilize` | Pinned companions (`versions.env`), pin guards, FIRST-BOOT-CHECKLIST, RELEASE notes | **Pending merge**; pins not assumed on published `:latest` |
| B | `lane/b-docs` | Operator handbook, first-boot chapter, keybind/INSTALL honesty | This branch — merge with other lanes via integrator |
| C | `lane/c-assistant` | Hyprwave Assistant (Go TUI / KB) | **Pending merge** until image hook |
| D | `lane/d-duress` | pam-duress packaging + setup tooling | **Pending merge**; **optional, off by default** — [docs/security.md](docs/security.md) |
| E | `lane/e-hyprland` | Keybind map (exit Super+Shift+E, vim focus/move/resize, dwindle splitratio), autostart/session smoke | **Pending merge**; handbook documents E map with merge note |
| F | `lane/f-cosmic` | Vendor Mode/dark, dock order, GREETER.md + SESSION-SMOKE | **Pending merge**; greeter limits called out in cosmic/first-boot |
| G | `lane/g-qa` | QA scripts, SMOKE-MATRIX, MERGE-PLAYBOOK | **Pending merge**; integration only |

### Removed vs older plans

- Wofi → Walker  
- swaybg → hyprpaper  
- Thunar as default → Yazi  
- Stock Firefox → Neonwolf  

### Known gaps

- GHCR may be **private** (403) until visibility is fixed — INSTALL calls this out;
  A’s first-boot logs still record anonymous pull **FAIL** as of 2026-08-06.
- Marketing screenshots not captured yet (checklist only).
- E2E “public pull + first boot both DEs” remains an ops / integrator proof item.

---

## Earlier history

- `8a623a2` — desktop stack polish, COSMIC variant, theme store, parallel plan  
- hyprlock Pango/label fix  
- Thunar → Yazi  

Add dated `## [YYYY-MM-DD]` sections when cutting published image milestones.
