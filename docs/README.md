# Hyprwave documentation

End-user docs for installing, using, and understanding Hyprwave.
You should not need the `planning/` directory or repo build internals for daily use.

## Start here

| Doc | Description |
|-----|-------------|
| [../INSTALL.md](../INSTALL.md) | Install via `bootc switch` or ISO; first login; post-install apps |
| [../README.md](../README.md) | Product overview, companions, themes |
| [../CHANGELOG.md](../CHANGELOG.md) | What ships / what changed |

## Using the desktop

| Doc | Description |
|-----|-------------|
| [keybinds.md](keybinds.md) | Hyprland keyboard shortcuts (Walker, terminal, themes, …) |
| [cosmic.md](cosmic.md) | COSMIC variant differences |
| [updating.md](updating.md) | `bootc upgrade`, reboot, Flatpak updates |
| [troubleshooting.md](troubleshooting.md) | Black screen, Walker empty, GHCR auth, wallpaper, … |

## Understanding the system

| Doc | Description |
|-----|-------------|
| [architecture.md](architecture.md) | bootc, skel caveat, theme store, two DE images |
| [security.md](security.md) | Immutable core, privacy defaults, duress off-by-default |

## Screenshots (not blocking)

Capture checklist and alt-text for future marketing shots:

- [../planning/integration/b-docs/screenshot-checklist.md](../planning/integration/b-docs/screenshot-checklist.md)

No screenshots are required to follow the install guide.

## Contributor-oriented (optional)

| Doc | Description |
|-----|-------------|
| [../CLAUDE.md](../CLAUDE.md) | Build commands and image layout for contributors |
| [../AGENTS.md](../AGENTS.md) | Deeper packaging patterns and gotchas |
| [../Justfile](../Justfile) | `just --list` for build/ISO/VM recipes |

## Image refs (quick)

```bash
# Hyprland (default)
ghcr.io/neon798/hyprwave:latest

# COSMIC
ghcr.io/neon798/hyprwave-cosmic:latest
```

> Packages may be **private** on GHCR until visibility is fixed — see INSTALL and
> troubleshooting if pulls return 403.
