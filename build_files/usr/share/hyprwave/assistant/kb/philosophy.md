# Hyprwave Philosophy

Hyprwave is built on **bootc** (bootable container) technology on top of Fedora Atomic / Universal Blue bases.

## Core principles

- **Immutable base** — The OS image is read-only. Normal use cannot corrupt the base system.
- **Atomic updates** — Updates apply as a whole image or not at all. Rollbacks are first-class.
- **Reproducible** — Everyone on the same image tag shares the same base packages and defaults.
- **Your home is mutable** — User data and `~/.config` are yours; the base is the vendor contract.
- **TUI-first tools** — Walker, Yazi, FlatArcade, Ghostty, and Hyprwave Assistant keep power users in the keyboard flow.

## Default apps

| Role | App |
|------|-----|
| Browser | Neonwolf |
| App store | FlatArcade (Flathub TUI) |
| Files | Yazi (in Ghostty) |
| Terminal | Ghostty |
| Launcher (Hyprland) | Walker + elephant (not Wofi) |
| Wallpaper (Hyprland) | hyprpaper (not swaybg) |
| Themes | 11 packs via `hyprwave-theme` |
| System companion | Hyprwave Assistant (Super+Shift+A on Hyprland) |
| Desktop | Hyprland **or** COSMIC (`hyprwave` / `hyprwave-cosmic`) |

Skel defaults apply to **new users only**. Duress is **OFF** in the stock image. GHCR packages **may be private** — see `ghcr`.

## Why not a traditional package manager for the base?

Traditional `dnf install` on a mutable root leads to “works on my machine” drift. Prefer:

1. **Flatpak** for GUI apps (sandboxed, updatable without rebasing).
2. **Image rebuild / layer** only when something must be on the host.
3. **Distrobox** when you need a fully mutable pet container for development.

This keeps the system secure, easy to reset, and easy to support.
