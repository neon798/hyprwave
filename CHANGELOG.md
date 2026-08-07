# Changelog

All notable user-facing changes to Hyprwave are documented here.
The format is inspired by [Keep a Changelog](https://keepachangelog.com/).

Hyprwave is distributed as bootable container images
(`ghcr.io/neon798/hyprwave`, `ghcr.io/neon798/hyprwave-cosmic`). Versions track image
tags and git history more than classic semver release tarballs.

---

## [Unreleased]

Current tree as of base `8a623a2` (desktop stack polish, COSMIC variant, theme store).
This section describes **what ships today**, not historical prototype apps.

### Desktop — Hyprland (default image)

- **Hyprland** compositor with split skel config (`hyprland.conf` sources fragments:
  envs, monitors, input, looknfeel, bindings, autostart, windowrules).
- **Walker** application launcher + **elephant** plugins (desktop apps, calc, runner,
  menus, websearch, files, providerlist). Wofi is **not** used.
- **hyprpaper** for wallpapers (swaybg is **not** used).
- **Waybar** status bar, **Mako** notifications, **hypridle** / **hyprlock**,
  **hyprpicker**, **hyprsunset**, and **hyprland-qtutils** (source-built utilities
  staged via the container builder).
- **SDDM** display manager with a custom synthwave QML theme (JetBrains Mono,
  chromatic title, shared default wallpaper).
- Default keybinds include Super+D / Super+Space (Walker), Super+R (runner),
  Super+Shift+T (theme GUI), Super+Return/T (Ghostty), Super+E (Yazi), Super+B
  (Neonwolf), Super+A (FlatArcade). Full list: [docs/keybinds.md](docs/keybinds.md).

### Desktop — COSMIC variant (`hyprwave-cosmic`)

- Second image: `DE=cosmic` → `ghcr.io/neon798/hyprwave-cosmic:latest`.
- Official Fedora `@cosmic-desktop-environment` + **cosmic-greeter** (no SDDM, no
  Hyprland stack).
- Vendor defaults under `/usr/share/cosmic/`: Hyprwave palette, default wallpaper,
  dock favorites (Neonwolf, Cosmic Files, Ghostty, FlatArcade, Cosmic Settings).
- Decluttered with safe removes: **cosmic-store** (replaced by FlatArcade),
  cosmic-edit / cosmic-player / cosmic-wallpapers as documented in the README.
- Shared companions still installed; skel limited to Ghostty / Yazi / theme
  indirection plus system COSMIC keys.

### Themes

- **11 switchable themes** under `/usr/share/hyprwave/themes/`:
  - `hyprwave` (default synthwave)
  - `retro-arcade`, `cozy-harvest`, `fjord-dark`, `touge-drive`, `vaporwave`
  - `highway-haze`, `lunar-pulse`, `glitch-horizon`, `arcade-rain`, `verdant-haven`
- **`hyprwave-theme`** CLI (`list`, `current`, `set`, `menu`) and **Hyprwave Themes**
  GUI (`hyprwave-theme-gui`, desktop entry, Super+Shift+T on Hyprland).
- Hyprland: live-reloads compositor UI, Waybar, Walker, Mako, hyprpaper, Ghostty
  via theme indirection symlink.
- COSMIC: applies appearance key trees + wallpaper + Ghostty.
- Optional SDDM theme refresh helper for Hyprland greeter wallpaper when switching
  packs (polkit-backed).

### Companion applications (both variants)

- **Neonwolf** — privacy-focused Firefox fork; AppImage extracted at build time to
  `/usr/lib/neonwolf/`, launcher `/usr/bin/neonwolf`.
- **FlatArcade** — synthwave Flathub TUI “app store”.
- **Yazi** — default file manager (terminal UI; Hyprland opens it in Ghostty).
- **Ghostty** — default terminal (COPR on Fedora).

### Platform / image

- Base: Universal Blue **`ghcr.io/ublue-os/base-main`** bootc image.
- Build: multi-stage `Containerfile` (`hyprbuilder` only for Hyprland utilities;
  COSMIC skips that stage).
- Recipes: `just build`, `just build-cosmic`, `just build-iso`, `just build-iso-cosmic`,
  `just build-qcow2`, `just run-vm-qcow2`, and cosmic equivalents.
- CI matrix builds **both** `hyprland` and `cosmic` images; signs with Cosign on push
  to `main` (PRs build without push/sign).
- Install path documentation: [INSTALL.md](INSTALL.md).

### Removed / not present (relative to older plans)

- **Wofi** — replaced by Walker.
- **swaybg** — replaced by hyprpaper (Hyprland).
- **Thunar** as default file manager — replaced by Yazi.
- Stock **Firefox** removed from the image in favor of Neonwolf.
- Planned-only features **not** in the image yet: Hyprwave Assistant TUI, duress
  password PAM (see `planning/`).

### Known gaps (docs / ops)

- External fetch URLs for Yazi / Neonwolf / FlatArcade may still track
  `/releases/latest` until the stabilizer lane pins versions.
- End-to-end public GHCR pull + first-boot VM proof is an ops checklist item, not a
  code deliverable of this changelog.
- Screenshots for marketing: see
  [planning/integration/b-docs/screenshot-checklist.md](planning/integration/b-docs/screenshot-checklist.md).

---

## Earlier history

Pre-Unreleased commits are summarized in git (`git log`). Notable recent product
commits before this changelog file:

- Desktop stack polish, COSMIC variant, theme store, parallel plan (`8a623a2`)
- hyprlock label / Pango markup fix
- Thunar → Yazi as file manager

Add dated `## [YYYY-MM-DD]` sections when cutting published image milestones.
