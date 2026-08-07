# Changelog

All notable user-facing changes to Hyprwave are documented here.
Format inspired by [Keep a Changelog](https://keepachangelog.com/).

Hyprwave ships as bootable container images
(`ghcr.io/neon798/hyprwave`, `ghcr.io/neon798/hyprwave-cosmic`). Tags and git history
matter more than classic tarball semver.

---

## [Unreleased]

### Status (honest merge state — pre-merge freeze)

Desktop features below describe the **product on `main` at base `8a623a2`** plus work
finished on **parallel Wave-1 lanes**. Lane deliverables remain **pending merge to
`main` / published GHCR `:latest`** until the integrator lands them (see G
`MERGE-PLAYBOOK` when present). Do **not** treat this Unreleased section as “already
on the public image.”

Docs on `lane/b-docs` (INSTALL, `docs/**`, this file) are frozen for integration
accuracy: claims distinguish **on main today** vs **lane-only until merge**.

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
- [docs/security.md](docs/security.md) — aligned to D-lane ENABLE/FAQ/THREAT-MODEL; **off by default**; not LUKS.
- [docs/troubleshooting.md](docs/troubleshooting.md) — dual-variant greeter/launcher/theme matrix.
- [docs/screenshots.md](docs/screenshots.md) + screenshot checklist with **exact** capture commands.
- [docs/README.md](docs/README.md) — handbook index.
- Operator pages: architecture, updating, cosmic, theming, [faq.md](docs/faq.md),
  [contributor-notes.md](docs/contributor-notes.md).
- [ACCURACY-AUDIT.md](planning/integration/b-docs/ACCURACY-AUDIT.md) — sources checked.
- Screenshot binaries still TODO (ops notes ready; not blocking).

### Wave-1 lane deliverables (**pending merge** — final honesty table)

Snapshot for integrators. **None of these rows are claimed shipped on main GHCR** until
their branch merges and CI publishes a new `:latest`.

| Lane | Branch | Deliverable (summary) | On main today? | Docs stance |
|------|--------|----------------------|----------------|-------------|
| A | `lane/a-stabilize` | Companion pins (`versions.env`), pin_guards CI, FIRST-BOOT-CHECKLIST, RELEASE/BUMP notes | **No** (pins still floating on main until A merges) | Pending merge; users upgrade published images only |
| B | `lane/b-docs` | Operator handbook (INSTALL, first-boot, keybinds, security, dual-variant TS, screenshots ops) | **No** (docs live on this lane until merge) | Merge with product lanes; then drop “pending” language |
| C | `lane/c-assistant` | Hyprwave Assistant (Go TUI / offline KB) | **No** | Pending image hook; optional, not stock UX |
| D | `lane/d-duress` | pam-duress **assets** + setup tooling + ENABLE/THREAT-MODEL | **No** | Pending merge; **optional, PAM off by default** — [docs/security.md](docs/security.md) |
| E | `lane/e-hyprland` | Keybind ENDPOINT (Super+Shift+E exit, vim move/resize, dwindle splitratio), autostart/session smoke | **No** (main still older binds) | Handbook documents E map + merge note |
| F | `lane/f-cosmic` | Vendor Mode/dark, dock order, GREETER.md, SESSION-SMOKE, declutter notes | **No** (partial base on main; F polish pending) | Greeter limits called out in cosmic/first-boot |
| G | `lane/g-qa` | QA scripts, SMOKE-MATRIX, MERGE-PLAYBOOK | **No** | Integration-only; not end-user surface |

### Post-merge template (for integrator)

After serial merge + green CI + (optional) GHCR publish, create a dated release section
and **flip** Unreleased language. Copy and edit:

```markdown
## [YYYY-MM-DD] — Wave 1 integration

### Merged from lanes

- [ ] A — companion pins + pin_guards (`versions.env`)
- [ ] B — operator handbook (`docs/**`, INSTALL, CHANGELOG honesty → this release)
- [ ] C — Hyprwave Assistant binary/package **if** image-hooked (else omit or “assets only”)
- [ ] D — duress **packaging only**; PAM remains **off by default**
- [ ] E — Hyprland skel keybinds / autostart ENDPOINT
- [ ] F — COSMIC vendor / greeter / session smoke docs
- [ ] G — QA scripts + smoke matrix (contributor path)

### Image refs

- `ghcr.io/neon798/hyprwave:<tag>`
- `ghcr.io/neon798/hyprwave-cosmic:<tag>`
- Digest / Cosign: (fill when public)

### Handbook cleanup after merge

- [ ] Remove “pending merge / lane-only” banners that no longer apply
- [ ] Keybinds: drop Super+M merge note if E is on the booted image
- [ ] Security: keep duress **off by default** even if assets shipped
- [ ] Assistant: only claim installed if `/usr/bin/hyprwave-assistant` is on the image
- [ ] ACCURACY-AUDIT: record merge commit + re-run link check
- [ ] Move remaining Unreleased bullets that still are not on the image back under Unreleased

### Known still-open (do not mark shipped)

- [ ] GHCR anonymous public pull (if still 403)
- [ ] Marketing screenshot binaries (`docs/assets/`)
- [ ] Full dual-variant E2E first-boot sign-off
```

Integrator also runs G’s merge playbook / smoke matrix when those files land on main.

### Removed vs older plans

- Wofi → Walker  
- swaybg → hyprpaper  
- Thunar as default → Yazi  
- Stock Firefox → Neonwolf  

### Known gaps (pre-merge)

- GHCR may be **private** (403) until visibility is fixed — INSTALL calls this out;
  A’s first-boot logs still record anonymous pull **FAIL** as of 2026-08-06.
- Marketing screenshots not captured yet (checklist + commands ready; no binaries).
- E2E “public pull + first boot both DEs” remains an ops / integrator proof item.
- Assistant + duress are **optional / packaging** features — never implied stock-on.

---

## Earlier history

- `8a623a2` — desktop stack polish, COSMIC variant, theme store, parallel plan  
- hyprlock Pango/label fix  
- Thunar → Yazi  

Add dated `## [YYYY-MM-DD]` sections when cutting published image milestones
(use the **Post-merge template** above).
