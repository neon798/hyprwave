# Changelog

All notable user-facing changes to Hyprwave are documented here.
Format inspired by [Keep a Changelog](https://keepachangelog.com/).

Hyprwave ships as bootable container images
(`ghcr.io/neon798/hyprwave`, `ghcr.io/neon798/hyprwave-cosmic`). Tags and git history
matter more than classic tarball semver.

---

## [Unreleased]

### Status (docs Wave 2)

Desktop features below describe the **product as implemented on the image branches**
(base `8a623a2` and parallel lanes). They are **pending merge to `main`** until the
integrator lands Wave 1+2. Do not assume every item is already on `origin/main` GHCR
`:latest` until a release merge happens.

Docs on `lane/b-docs` (INSTALL, docs tree, this file) document that reality for
onboarding without requiring readers to open `planning/`.

### Desktop — Hyprland (default image)

- **Hyprland** with split skel (`hyprland.conf` sources envs, monitors, input,
  looknfeel, bindings, autostart, windowrules).
- **Walker** + **elephant** plugins (apps, calc, runner, menus, websearch, files,
  providerlist). **Not Wofi.**
- **hyprpaper** wallpapers. **Not swaybg.**
- **Waybar**, **Mako**, **hypridle** / **hyprlock**, **hyprpicker**, **hyprsunset**,
  **hyprland-qtutils** (source-built in container builder stage).
- **SDDM** + custom synthwave QML theme.
- Keybinds: Super+D/Space (Walker), Super+R (runner), Super+Shift+T (themes),
  Super+Return/T (Ghostty), Super+E (Yazi), Super+B (Neonwolf), Super+A (FlatArcade).
  See [docs/keybinds.md](docs/keybinds.md).

### Desktop — COSMIC (`hyprwave-cosmic`)

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

### Documentation (this lane — handbook)

- [INSTALL.md](INSTALL.md) — Atomic rebase + ISO; private GHCR contingency; first hour.
- [docs/README.md](docs/README.md) — full handbook index.
- Operator pages: troubleshooting, architecture, updating, security, cosmic, theming,
  keybinds, [faq.md](docs/faq.md) (≥12 Q&As), [contributor-notes.md](docs/contributor-notes.md).
- [ACCURACY-AUDIT.md](planning/integration/b-docs/ACCURACY-AUDIT.md) — sources checked.
- Screenshot checklist: purpose + alt text + capture notes (binaries still TODO).

### Parallel lanes (not claimed shipped on main until merge)

| Lane | Feature | Docs stance |
|------|---------|-------------|
| A | Pinned Yazi/Neonwolf/FlatArcade (`versions.env` on `lane/a-stabilize`) | **Pending merge to main**; users still `bootc upgrade` published images |
| C | Hyprwave Assistant (Go TUI) | **Pending merge / dormant** until integrator hooks image |
| D | pam-duress packaging | **Pending merge**; **optional, off by default** — [docs/security.md](docs/security.md) |

### Removed vs older plans

- Wofi → Walker  
- swaybg → hyprpaper  
- Thunar as default → Yazi  
- Stock Firefox → Neonwolf  

### Known gaps

- GHCR may be **private** (403) until visibility is fixed — INSTALL calls this out.
- Marketing screenshots not captured yet (checklist only).
- E2E “public pull + first boot both DEs” remains an ops proof item.

---

## Earlier history

- `8a623a2` — desktop stack polish, COSMIC variant, theme store, parallel plan  
- hyprlock Pango/label fix  
- Thunar → Yazi  

Add dated `## [YYYY-MM-DD]` sections when cutting published image milestones.
