# Hyprwave TUI Universal Updater & Installer — Planning Document

**Status:** SUPERSEDED by `HYPRWAVE-ASSISTANT.md` (this plan was expanded into the Hyprwave Assistant).
Note: language references to Rust + ratatui below are outdated — the assistant will be written in **Go + Bubble Tea** (user decision 2026-07-07).
**Do not implement in main tree** without Claude handoff verification (per project rules and previous AGENTS.md / planning process).

## Overview

Create a single, polished TUI tool (in the spirit of FlatArcade) that serves as:

1. **Universal Updater** — One place to check & apply updates for the immutable base (bootc / rpm-ostree), Flatpaks, and other components.
2. **Easy One-Click Installer** — Curated, categorized list of popular software with one-keystroke or mouse-free install.

The tool should feel native to Hyprwave (synthwave / retro aesthetic by default, themable), be written in Rust + ratatui (matching FlatArcade), and live at `/usr/bin/hyprwave-tui` (or `hyprwave` with subcommand `tui`).

Command-line usage examples:
```bash
hyprwave update          # quick CLI update (or launch TUI)
hyprwave install steam   # direct
hyprwave-tui             # full TUI
```

## Goals & Acceptance Criteria

- Single binary, small, fast startup.
- Works on both Hyprland and COSMIC variants.
- Uses official channels only (Flathub for apps, official repos or layering for system tools).
- "One click" = select item + confirm (or hotkey). No typing package names.
- Clear feedback: progress, success, "reboot required" warnings.
- Safe: never force-reboot without confirmation; show what will be installed/updated.
- Theming support (leverage existing hyprwave / new nature themes).
- Pre-installed in the base image.
- Easy to extend the catalog (TOML/JSON file or embedded list).

## Proposed Name & Branding

**Internal name:** `hyprwave-tui`

**User-facing:** `hyprwave` (with `hyprwave tui` or just launching the binary shows TUI by default).

Theme name in ratatui: "hyprwave" (default) with support for other planned themes.

## Core Features

### 1. Universal Updater Screen

Tabs or sections:
- **System / Base Image**
  - Current image ref + version
  - `bootc status` / `rpm-ostree status` summary
  - Button: "Check for updates" → "Update base image" (runs `bootc update` or `rpm-ostree upgrade`)
  - Warning if staged update requires reboot
- **Flatpaks (User + System)**
  - List outdated Flatpaks
  - "Update all Flatpaks" button
  - Per-app update
- **Other** (Tailscale, etc. if they have their own updater)
- Combined "Update Everything" big button with summary of what will change.

After update actions, offer "Reboot now" if needed.

### 2. One-Click Installer

Categorized, searchable list.

Categories (initial):
- **Office & Productivity**
  - LibreOffice (Flatpak)
  - OnlyOffice (alternative)
- **Gaming**
  - Steam (Flatpak recommended for Atomic)
  - Heroic Games Launcher
  - Lutris
  - Bottles
  - Utilities: Gamemode, MangoHud, Proton-GE (via ProtonUp-Qt), Gamescope
- **Networking & Remote**
  - Tailscale
  - WireGuard tools / Mullvad VPN
  - Syncthing
- **Privacy & Browsers**
  - LibreWolf
  - Mullvad Browser
  - Tor Browser
  - (Neonwolf is already default)
- **Development**
  - VSCodium
  - Zed
  - Distrobox (for mutable environments)
- **Media & Communication**
  - VLC / MPV
  - Element (Matrix)
  - Signal Desktop
- **System Tools**
  - btop / htop (if not present)
  - ncdu, fastfetch enhancements, etc.

Each item shows:
- Name + short description
- Source (Flathub / COPR / layered)
- Size estimate
- "Install" button (or [I] hotkey)

Installation flow:
1. Select → Confirm dialog ("This will install X. Continue?")
2. Run appropriate command in a sub-process with live output in TUI (ratatui + tokio or similar).
3. On success: mark as installed, offer "Launch" or "Reboot if needed".
4. Errors shown clearly.

For layered packages (rare, only when necessary): clear "Reboot required after install" banner.

### 3. Additional Nice-to-Haves

- Search / filter (fuzzy)
- "Recently installed" or "Favorites"
- Integration with FlatArcade (button to open FlatArcade for more)
- "Layer custom package" advanced mode (with warning)
- Update check on launch (with "Update available" banner)
- Theming picker (if multiple themes installed)
- Log viewer for previous operations
- "Rebase to different variant" helper (Hyprland <-> COSMIC)

## Technical Implementation (Theoretical)

**Language/Stack (recommended):**
- Rust + ratatui + crossterm (exact match to FlatArcade)
- tokio for async commands
- clap for CLI
- toml or json for the software catalog (easy to extend)

**Catalog format example (embedded or /usr/share/hyprwave/installer/catalog.toml):**

```toml
[[category]]
name = "Gaming"
items = [
  { id = "steam", name = "Steam", source = "flathub", flatpak = "com.valvesoftware.Steam", description = "..." },
  { id = "gamemode", name = "GameMode", source = "layer", package = "gamemode", description = "..." },
]
```

**Commands the tool will run (safely):**
- Flatpak: `flatpak install --user --noninteractive flathub <id>`
- Layered: `rpm-ostree install <pkg>` (or future `bootc` equivalent) + warn reboot
- Updates: `bootc update`, `flatpak update --user`, `flatpak update --system`

**Installation in image:**
- Add to `build_files/build.sh` (shared section):
  - `dnf5 install -y ...` (any build deps if needed)
  - Build or install the `hyprwave-tui` binary (ideally pre-built or simple cargo build in a stage)
  - `cp hyprwave-tui /usr/bin/`
  - Deploy catalog + desktop entry so it appears in Walker / COSMIC launcher
  - Optional: autostart update check notification (via mako or cosmic)

**Desktop integration:**
- `.desktop` file: `Exec=ghostty -e hyprwave-tui` (consistent with Yazi/FlatArcade)
- Or direct TUI launch if possible (some ratatui apps do graphical too, but keep terminal for now)
- Walker prefix or menu entry

## Other Suggestions for the Catalog (curated, privacy & spirit friendly)

**Strongly recommended additions:**
- **Syncthing** — file sync, excellent for privacy
- **Obsidian** (Flatpak) — note taking (very popular)
- **VSCodium** — VS Code without telemetry
- **Element** (Matrix client)
- **Mullvad VPN** or **Proton VPN** clients
- **Bitwarden** (desktop)
- **Distrobox** — for when you really need mutable tools
- **Bottles** — for Windows apps/games (complements Steam)
- **ProtonUp-Qt** — easy Proton-GE management
- **Timeshift** or native ostree rollback helper (but atomic has good rollback already)
- **btop** (if not already present)
- **KeePassXC**
- **VeraCrypt**
- **Signal Desktop**
- **Jellyfin Media Player** or **Kodi**
- **OnlyOffice** (as lighter LibreOffice alternative)

**Avoid or mark carefully:**
- Anything that requires heavy layering or breaks atomicity badly.
- Closed-source without good Flatpak (Discord is common but privacy note it).
- Things that pull in lots of deps.

## File Layout (Theoretical)

```
planning/
├── TUI-UPDATER-INSTALLER.md
├── theoretical/
│   └── hyprwave-tui/
│       ├── src/
│       │   ├── main.rs          # ratatui app skeleton
│       │   ├── catalog.rs
│       │   ├── updater.rs
│       │   └── installer.rs
│       ├── Cargo.toml
│       └── catalog.toml
├── bin/
│   └── apply-...sh              # will be extended to install the binary + catalog
└── ...
```

## Risks & Mitigations

- **rpm-ostree layering can bloat the image** → Prefer Flatpaks. Only layer when necessary (Tailscale, Gamemode, etc.). Document clearly.
- **User runs update and loses work** → Always show "reboot required" and let user choose when.
- **Flatpak vs system package confusion** → Clear labels in the TUI ("User Flatpak", "System Layer").
- **Theming consistency** → Use existing color definitions from the theme system.
- **COSMIC vs Hyprland differences** → Abstract the update/install commands; test both.

## Handoff Checklist (for Claude)

- [ ] Review this document + theoretical/ directory
- [ ] Decide on final binary name and command structure
- [ ] Choose exact catalog (Flatpak IDs, layered packages)
- [ ] Implement the ratatui TUI (or decide if a simpler dialog/whiptail version is acceptable for size)
- [ ] Add build steps to `build_files/build.sh` (shared + per-variant)
- [ ] Deploy desktop entry, icon (reuse or new), and catalog file
- [ ] Add to autostart or Walker config if desired
- [ ] Update README.md and CLAUDE.md
- [ ] Ensure `just lint` + `bootc container lint` still happy
- [ ] Test on both variants (build + VM)
- [ ] Make the catalog easily updatable without full rebuild

## Open Questions

- Should the tool also manage "layered" packages in a nice way, or keep it mostly Flatpak-focused?
- One binary that does both CLI flags and TUI, or separate `hyprwave-tui` binary?
- How aggressive should the "Update Everything" button be?
- Include a "Rebase" helper for switching between Hyprland <-> COSMIC images?

---

**Everything above is planning material only.**  
Ready for Claude to turn into actual code + build integration when approved. No main files have been modified.