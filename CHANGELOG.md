# Changelog

All notable user-facing changes to Hyprwave are documented here.
Format inspired by [Keep a Changelog](https://keepachangelog.com/).

Hyprwave ships as bootable container images
(`ghcr.io/neon798/hyprwave`, `ghcr.io/neon798/hyprwave-cosmic`). Tags and git history
matter more than classic tarball semver.

---

## [Unreleased]

### Status

Wave 1 lanes **A–G are on `main`** (serial merge 2026-08-13; tag
`post-integration-20260807`). Product paths (pins, handbook, assistant, duress
packaging, Hyprland/COSMIC polish, QA harness) live on this branch.

**Published GHCR `:latest` is not automatically this tip.** Confirm with
`bootc status` / image digest before assuming a `bootc upgrade` already contains
Wave 1. Local rebuild: `just build` / `just build-cosmic`.

### Still open (ops)

- Dual-variant image rebuild + VM smoke from the merged tip (T8)
- GHCR anonymous public pull (may still 403 — [INSTALL.md](INSTALL.md))
- Marketing screenshot binaries (`docs/assets/`)
- `PROGRAM_COMPLETE` after T8 + residual closeout

### Post-merge template (for later waves)

**Full doc flip checklist (files, greps, honesty rules):**
[planning/integration/b-docs/POST-MERGE-DOC-FLIP.md](planning/integration/b-docs/POST-MERGE-DOC-FLIP.md)

```markdown
## [YYYY-MM-DD] — <wave name>

### Merged from lanes
- [ ] …

### Image refs
- `ghcr.io/neon798/hyprwave:<tag>`
- Digest / Cosign: (fill when public)

### Known still-open
- [ ] …
```

### Removed vs older plans

- Wofi → Walker
- swaybg → hyprpaper
- Thunar as default → Yazi
- Stock Firefox → Neonwolf

---

## [2026-08-13] — Wave 1 integration

Serial merge **A→B→C→D→E→F→G** onto `main` (integrator + snippet apply). Host
harness `planning/qa/run-all.sh` → **RESULT OK**. Pins fail-closed
(`build_files/versions.env`; no `/releases/latest` in `build.sh`).

### Merged from lanes

- [x] A — companion pins + pin_guards (`versions.env`)
- [x] B — operator handbook (`docs/**`, INSTALL, CHANGELOG)
- [x] C — Hyprwave Assistant **image-hooked** (Containerfile stage + `/usr/bin/hyprwave-assistant`; Super+Shift+A)
- [x] D — duress **packaging only**; PAM remains **off by default**
- [x] E — Hyprland skel keybinds / autostart ENDPOINT
- [x] F — COSMIC vendor / greeter / session smoke docs
- [x] G — QA scripts + smoke matrix (contributor path)

### Image refs

- CI (2026-08-13, run on `77755f1`): **Build and push** succeeded for **hyprland** and **cosmic**
- Registry: `ghcr.io/neon798/hyprwave` / `hyprwave-cosmic` (package is **not** anonymously public — pull still 403 without credentials)
- Local rebuild: `just build` / `just build-cosmic`

### Desktop — Hyprland (default image)

- **Hyprland** with split skel (`hyprland.conf` sources envs, monitors, input,
  looknfeel, bindings, autostart, windowrules).
- **Walker** + **elephant** plugins (apps, calc, runner, menus, websearch, files,
  providerlist, clipboard, symbols). **Not Wofi.**
- **hyprpaper** wallpapers. **Not swaybg.**
- **Waybar**, **Mako**, **hypridle** / **hyprlock**, **hyprpicker**, **hyprsunset**,
  **hyprland-qtutils** (source-built in container builder stage).
- **SDDM** + custom synthwave QML theme (switchable copy under `/etc/sddm/themes`).
- Keybinds: Super+D/Space (Walker), Super+R (runner), Super+Shift+T (themes),
  Super+Shift+A (Assistant), Super+Shift+E (exit), Super+Return/T (Ghostty),
  Super+E (Yazi), Super+B (Neonwolf), Super+A (FlatArcade).
  Map: [docs/keybinds.md](docs/keybinds.md).

### Desktop — COSMIC (`hyprwave-cosmic`)

- `DE=cosmic` → `ghcr.io/neon798/hyprwave-cosmic` (after publish).
- Fedora `@cosmic-desktop-environment` + **cosmic-greeter** (no SDDM / Hyprland stack).
- Vendor `/usr/share/cosmic/` defaults: palette, wallpaper, dock favorites
  (Neonwolf, FlatArcade, Ghostty, Cosmic Files, Hyprwave Themes, Settings).
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
- **Hyprwave Assistant** — offline TUI (KB + catalog); Super+Shift+A on Hyprland.

### Platform

- Base: Universal Blue **`ghcr.io/ublue-os/base-main`**.
- Pinned companions: [build_files/versions.env](build_files/versions.env).
- `just build` / `build-cosmic` / `build-iso` / `build-iso-cosmic` / VM recipes.
- CI matrix: hyprland + cosmic; Cosign sign on push to `main` (PRs build only).
- Install / update docs: [INSTALL.md](INSTALL.md), [docs/updating.md](docs/updating.md).

### Security packaging

- pam-duress **assets** and `hyprwave-duress-setup` ship; **PAM is not enabled**.
- Enablement is an admin post-boot step: [docs/security.md](docs/security.md).

### Documentation

- [INSTALL.md](INSTALL.md) — dual-variant decision tree; ISO vs rebase; private GHCR.
- [docs/first-boot.md](docs/first-boot.md) — login → desktop → apps → themes → updates.
- [docs/keybinds.md](docs/keybinds.md) — matches skel `bindings.conf`.
- [docs/security.md](docs/security.md) — **duress off by default**; not LUKS.
- [docs/troubleshooting.md](docs/troubleshooting.md) — dual-variant greeter/launcher/theme matrix.
- [docs/README.md](docs/README.md) — handbook index.

### Known still-open (do not mark shipped)

- [ ] GHCR anonymous public pull (if still 403)
- [ ] Marketing screenshot binaries (`docs/assets/`)
- [ ] Full dual-variant E2E first-boot sign-off from this tip

---

## Earlier history

- `8a623a2` — desktop stack polish, COSMIC variant, theme store, parallel plan
- hyprlock Pango/label fix
- Thunar → Yazi

Add dated `## [YYYY-MM-DD]` sections when cutting published image milestones
(use the **Post-merge template** under Unreleased).
