# Hyprwave Philosophy

Hyprwave is built on **bootc** (bootable container) technology on top of Fedora Atomic.

## Core Principles
- **Immutable base**: The operating system image is read-only. You cannot break the base with normal use.
- **Atomic updates**: Updates are applied as a whole or not at all. Easy rollbacks.
- **Reproducible**: Everyone on the same image tag has the exact same base system.
- **User data is yours**: Your home directory and configs are the mutable parts.
- **TUI-first**: Powerful terminal tools (Walker, Yazi, FlatArcade, Ghostty, now Hyprwave Assistant).

## Default Apps Philosophy
- Neonwolf (privacy browser)
- FlatArcade (TUI Flathub manager)
- Yazi (blazing fast file manager)
- Ghostty (terminal)
- Hyprland (or COSMIC) as the desktop

## Why No Traditional Package Manager for Base?
Because it leads to "it worked on my machine" problems and un-reproducible systems. Use Flatpaks for apps, layering sparingly, and Distrobox when you need a mutable environment.

This design makes the system more secure and easier to maintain long-term.
