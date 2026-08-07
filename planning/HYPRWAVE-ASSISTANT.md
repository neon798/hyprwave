# Hyprwave Assistant — Planning Document

**Status:** Theory / Planning only.  
**Do not implement in main tree** without Claude handoff verification (per project rules).

## Overview

**Name:** Hyprwave Assistant (command: `hyprwave-assistant` or simply `hyprwave` with TUI default)

A single, polished TUI application (**Go + Bubble Tea/Lip Gloss**, matching the aesthetic of FlatArcade) that expands beyond a simple updater/installer into a **central assistant** for the distro. (Language decision per user, 2026-07-07: Go, not Rust — FlatArcade stays Rust in its own repo.)

Core scopes:
1. **Universal Updater** — Check and apply updates for the immutable base (bootc), Flatpaks, and other components.
2. **One-Click Installer** — Curated, categorized list of popular software with easy install (LibreOffice, Steam + gaming stack, Tailscale, secure browsers, etc.).
3. **Knowledge Base** — "Need to know" information about Hyprwave. Searchable or navigable reference for distro philosophy, key features, troubleshooting, configuration, and "how things work here".

The tool should feel native (themed to current Hyprwave theme pack: synthwave default + others like verdant-haven, etc.). Pre-installed in the image. Works on both Hyprland and COSMIC variants.

## Goals

- Single entry point for common tasks and learning the distro.
- "One click" feel for installs and updates.
- Educational: users learn the immutable/atomic nature, theming system, security features (duress), etc. without leaving the TUI.
- Easy to extend (catalog + KB content in TOML/JSON or separate files).
- Theming support.
- Fast, keyboard-driven, beautiful Bubble Tea interface.

## Proposed Structure in TUI

Main screen with tabs/sections (Bubble Tea model with tabbed views):

- **Updater**
  - System/Base status (`bootc status`)
  - Flatpak status
  - Buttons: Check / Update Base / Update Flatpaks / Update All
  - Progress + reboot warning

- **Installer**
  - Searchable, categorized list (Office, Gaming, Networking, Privacy, etc.)
  - One-click install with confirmation and live output
  - Source indication (Flatpak / layered)
  - Post-install actions (launch, reboot note)

- **Knowledge Base**
  - Search bar (fuzzy search across entries)
  - Categorized or tagged articles:
    - Getting Started
    - Updates & Maintenance
    - Theming & Customization
    - Keybindings & Workflow
    - Security (including Duress)
    - Variants (Hyprland vs COSMIC)
    - Troubleshooting
    - Philosophy (immutable bootc, /etc/skel, etc.)
    - Extending the system
  - Each entry is readable in-pane (markdown rendered simply or plain text)
  - "Related" links or quick actions (e.g., "Open Installer for Tailscale")

- **Settings / About**
  - Current theme
  - Distro version / image ref
  - Links to docs or GitHub

CLI fallbacks:
```bash
hyprwave update
hyprwave install steam
hyprwave kb "duress password"
hyprwave assistant   # launches full TUI
```

## Catalog (Installer) — Updated from Previous

Keep previous suggestions and expand slightly for completeness:

**Office**
- LibreOffice
- OnlyOffice

**Gaming**
- Steam
- Heroic
- Lutris
- Bottles
- Gamemode + MangoHud (layered)

**Networking**
- Tailscale
- Syncthing
- Mullvad / Proton VPN

**Privacy & Browsers**
- LibreWolf
- Mullvad Browser
- Tor Browser

**Development & Tools**
- VSCodium
- Zed
- Distrobox
- btop (if not base)

**Other strong candidates** (user is open to suggestions):
- Obsidian (notes)
- Bitwarden (passwords)
- Element (Matrix chat)
- Signal Desktop
- Jellyfin Media Player
- KeePassXC
- Veracrypt
- Podman Desktop or just good Distrobox workflows

Catalog lives in `catalog.toml` for easy editing.

## Knowledge Base Content — "Need to Know"

Structure as a set of short, focused articles (can be markdown files loaded at runtime or compiled in).

Suggested initial KB articles:

1. **Hyprwave Philosophy**
   - Immutable bootc image
   - /etc/skel for defaults (new users only)
   - No traditional package manager for base
   - Atomic updates + easy rebase between variants

2. **Updates**
   - `bootc update` vs Flatpak
   - When to reboot
   - How to check status
   - Rebase between Hyprland and COSMIC

3. **Theming**
   - Current theme system
   - How to switch (once implemented)
   - Wallpapers live in `/usr/share/hyprwave/wallpapers`
   - SDDM / COSMIC greeter theming

4. **Workflow & Keybindings**
   - Default Hyprland keybinds (Super + ...)
   - Walker launcher (Super+D, Super+R, etc.)
   - Ghostty + Yazi as core
   - Hyprlock / Hypridle

5. **Security Features**
   - Duress password (link to dedicated setup)
   - Flatpak sandboxing
   - Immutable nature benefits

6. **FlatArcade**
   - How to use the TUI store
   - Difference from this Assistant

7. **Troubleshooting**
   - Common issues after update
   - Resetting configs (new user or overlay)
   - Booting previous image
   - Reporting bugs

8. **Extending the System**
   - When to use Flatpak vs layering
   - Distrobox for dev
   - Custom scripts in ~/.config/hypr
   - Contributing themes or KB entries

9. **Variant Differences**
   - Hyprland vs COSMIC (greeter, launcher, etc.)
   - Shared components (Neonwolf, FlatArcade, Yazi, Ghostty)

KB content should be concise, actionable, and link back to actions in the TUI (e.g., "Install LibreOffice" button from the KB page).

## Technical Notes (Theoretical)

- **Language:** **Go** with Bubble Tea (TUI framework) + Lip Gloss (styling) + Bubbles (widgets). Static single binary (CGO_ENABLED=0), fast to compile in a Containerfile builder stage with `golang` base — no Rust toolchain needed. Visual consistency with FlatArcade comes from the shared synthwave palette, not the framework.
- **Data:**
  - `catalog.toml` for installer items
  - `kb/` directory with .md or simple structured files (or a single `knowledge.toml`)
- **Deployment:**
  - Binary to `/usr/bin/hyprwave-assistant`
  - Assets to `/usr/share/hyprwave/assistant/`
  - Desktop entry: `Exec=ghostty -e hyprwave-assistant`
- **Build integration** (in `build.sh`):
  - Build or include the binary
  - Deploy catalog + KB files
  - Optional: create a simple `hyprwave` wrapper script
- **Integration:**
  - Accessible from Walker (Super + something)
  - Theming pulled from current Hyprwave theme
  - Can call out to existing tools (e.g., launch FlatArcade, open specific KB)

## Files to Create (Theoretical)

See `planning/theoretical/hyprwave-assistant/` for:
- go.mod
- Basic Bubble Tea app skeleton with tabs for Updater / Installer / Knowledge Base
- catalog.toml
- kb/ directory with sample articles (markdown)
- desktop entry
- Example of how it would be deployed in build.sh

## Handoff Checklist

- [ ] Finalize name and binary placement
- [ ] Flesh out full KB content (start with the 9 articles above)
- [ ] Implement TUI navigation + search for KB
- [ ] Wire actual `bootc` / `flatpak` commands with proper async output
- [ ] Add to image build (binary + data)
- [ ] Desktop entry + Walker integration
- [ ] Theming hooks
- [ ] Update README, CLAUDE.md, and any "getting started" docs
- [ ] Test on both variants
- [ ] Ensure it stays lean (no heavy deps)

This turns the previous "updater + installer" into a proper **Hyprwave Assistant** that also teaches users how the distro works.

All work remains in `planning/`. Ready for Claude review.