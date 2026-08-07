# Hyprwave

Hyprwave is a modern, privacy- and security-first Linux distribution based on Fedora Atomic, featuring Hyprland as the default desktop environment. It combines an immutable, container-friendly core with a fast, composited Wayland desktop to deliver a safe, polished, and highly tweakable experience.

## Install

| Variant | Image | Greeter |
|---------|-------|---------|
| **Hyprland** (default) | `ghcr.io/neon798/hyprwave:latest` | SDDM |
| **COSMIC** | `ghcr.io/neon798/hyprwave-cosmic:latest` | cosmic-greeter |

```bash
sudo bootc switch ghcr.io/neon798/hyprwave:latest && sudo systemctl reboot
# or COSMIC:
sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest && sudo systemctl reboot
```

Full guide (variant pick, ISO vs rebase, first login): **[INSTALL.md](INSTALL.md)** ·
**[docs/first-boot.md](docs/first-boot.md)**.

> **Registry note:** GHCR packages may be **private** until visibility is fixed. If
> `bootc switch` / `podman pull` returns 403, see INSTALL or build from source.

**Docs:** [Handbook index](docs/README.md) ·
**[First boot](docs/first-boot.md)** ·
**[Keybinds](docs/keybinds.md)** ·
**[Security](docs/security.md)** (duress **off by default**) ·
[FAQ](docs/faq.md) ·
[Install](INSTALL.md) ·
[Updating](docs/updating.md) ·
[Troubleshooting](docs/troubleshooting.md) ·
[Theming](docs/theming.md) ·
[COSMIC](docs/cosmic.md) ·
[Architecture](docs/architecture.md) ·
[Screenshots](docs/screenshots.md) ·
[Changelog](CHANGELOG.md)

## Default stack (Hyprland)

| Piece | Choice |
|-------|--------|
| Compositor | Hyprland |
| Launcher | Walker (+ elephant) |
| Bar | Waybar |
| Notifications | Mako |
| Wallpaper | hyprpaper |
| Terminal | Ghostty |
| Browser | Neonwolf |
| Files | Yazi |
| App store | FlatArcade |
| Themes | 11 packs via `hyprwave-theme` / Super+Shift+T |

COSMIC variant differences: [docs/cosmic.md](docs/cosmic.md).

## Companion apps

Hyprwave ships with a small suite of synthwave-themed apps that share its `synthwave84` look:

| | App | What it is |
|---|---|---|
| 🕹️ | **[FlatArcade](https://github.com/neon798/flatarcade)** | A synthwave 8-bit arcade TUI for browsing Flathub and managing Flatpaks. Rust + ratatui. |
| 🐺 | **[Neonwolf](https://github.com/neon798/neonwolf)** | A synthwave, privacy-focused Firefox fork — a thin neon overlay on LibreWolf. |

## SDDM Theme

Hyprwave ships with a custom QML-based SDDM login theme (`build_files/usr/share/sddm/themes/hyprwave/`) that matches the synthwave aesthetic:

- **Palette**: Deep purple background (`#15052e`), pink accents (`#ff2d95`), cyan highlights (`#00f0ff`), purple trim (`#b967ff`), and light foreground (`#e0e0ff`)
- **Typography**: JetBrains Mono throughout — titles, labels, inputs, and power controls
- **Title**: Chromatic "HYPRWAVE" header with offset cyan and pink ghost layers for a retro arcade CRT feel
- **Login panel**: Centered card with a double-border effect (pink outer + cyan inner), monospace "USER" / "PASSWORD" labels, user selector, password field, and a "▶ START" button
- **Clock**: Top-right 24-hour clock with date subtitle
- **Power controls**: Bottom-right SHUTDOWN / REBOOT / SUSPEND links
- **Background**: Same wallpaper as the desktop (`/usr/share/hyprwave/wallpapers/default.png`), darkened with a purple vignette overlay for legibility

The theme is set as the SDDM default in `build_files/build.sh` via `/etc/sddm.conf.d/10-hyprwave.conf`. The palette is defined in `theme.conf` and referenced by the QML theme file; all colors have safe fallbacks if the config key is missing.

See the whole suite at **[github.com/neon798](https://github.com/neon798)**.

## COSMIC variant

Hyprland remains the default desktop. A second image variant ships the **COSMIC desktop environment** (System76's Rust-based DE) as `hyprwave-cosmic`, now with full Hyprwave synthwave identity:

- Default theme: deep purple background (`#15052e`), light foreground (`#e0e0ff`), pink accent (`#ff2d95`), cyan window hint (`#00f0ff`), purple neutral tint (`#b967ff`).
- Default wallpaper: the Hyprwave default (synthwave).
- Dock favorites: Neonwolf (browser), CosmicFiles, Ghostty (terminal), FlatArcade (app store), CosmicSettings.
- Removed apps (decluttered with `--no-autoremove`): cosmic-store (replaced by FlatArcade), cosmic-edit (use geany), cosmic-player (use mpv), cosmic-wallpapers (use hyprwave wallpaper). cosmic-term is kept (required by cosmic-session); Ghostty remains the promoted terminal.

- Image: `ghcr.io/neon798/hyprwave-cosmic:latest`
- Rebase an existing Hyprwave install: `sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest`
- Local build: `just build-cosmic`
- ISO: `just build-iso-cosmic`

Shared components on both variants: Neonwolf (browser), FlatArcade (Flathub TUI), Yazi (file manager), Ghostty (terminal), CLI tools, fonts, wallpapers.

The COSMIC image uses `cosmic-greeter` (no SDDM) and does not include Hyprland-specific packages or dotfiles (walker, waybar, mako, hypr configs). It installs the official Fedora `@cosmic-desktop-environment` group plus `cosmic-greeter`. Vendor defaults for the desktop (dock, wallpaper) are overridden from `build_files/usr/share/cosmic/`.

## Themes

Hyprwave ships 11 switchable themes for the Hyprland variant (the default `hyprwave` synthwave theme plus 10 additional packs).

- hyprwave (default): classic synthwave
- retro-arcade: 80s arcade cabinets
- cozy-harvest: warm earthy farm life
- fjord-dark: clean cold nordic
- touge-drive: night mountain racing
- vaporwave: 80s/90s vapor
- highway-haze: misty neon drive
- lunar-pulse: dreamy moonlit
- glitch-horizon: glitchy retro future
- arcade-rain: rainy neon arcade
- verdant-haven: immersive nature

### GUI (recommended)

Open **Hyprwave Themes** from the app launcher (on COSMIC it’s also pinned to the dock).  
Hyprland shortcut: **`Super+Shift+T`**.

Pick a theme and click **Apply theme** — no terminal needed.

### CLI (optional)

```bash
hyprwave-theme list
hyprwave-theme set vaporwave
hyprwave-theme menu    # launches the same GUI in a graphical session
```

Theme store: `/usr/share/hyprwave/themes/`. Ghostty picks up colors on new windows. COSMIC writes Appearance + wallpaper under `~/.config/cosmic/`; Hyprland live-reloads borders/waybar/walker/mako/hyprpaper.

## Upcoming (optional)

Not required for a usable desktop; may land after parallel lanes merge into the published image:

| Feature | Notes |
|---------|--------|
| **Hyprwave Assistant** | Go TUI for updates / Flatpak / knowledge base — treat as **upcoming** until listed as shipped in the changelog |
| **Duress password** | Optional PAM tooling — **off by default**; never enabled on a stock install. Overview: [docs/security.md](docs/security.md) |

## Building from source

```bash
just build hyprwave latest
just build-cosmic
just build-iso            # needs sudo
just build-iso-cosmic
```

See [INSTALL.md](INSTALL.md) and [docs/architecture.md](docs/architecture.md). Contributor-oriented build detail: [CLAUDE.md](CLAUDE.md).

