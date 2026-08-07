# Hyprwave documentation (handbook)

End-user and light contributor docs. You should not need `planning/` theory files for
daily install and use.

## Start here

| Doc | Description |
|-----|-------------|
| [../INSTALL.md](../INSTALL.md) | Variant pick; Atomic rebase vs ISO; private GHCR |
| [first-boot.md](first-boot.md) | Login → wallpaper/bar/launcher → apps → themes → updates |
| [keybinds.md](keybinds.md) | Hyprland Super+ shortcuts (E KEYBIND-MAP) |
| [security.md](security.md) | Immutable core; duress **off by default**; no LUKS claims |
| [../README.md](../README.md) | Product overview, stack, companions, themes |
| [../CHANGELOG.md](../CHANGELOG.md) | What ships / Unreleased lane reality (pending merge) |
| [faq.md](faq.md) | ≥12 frequent questions |

## Using the desktop

| Doc | Description |
|-----|-------------|
| [theming.md](theming.md) | 11 themes, GUI/CLI switcher, palette |
| [cosmic.md](cosmic.md) | COSMIC variant; F greeter/session smoke cross-links |
| [updating.md](updating.md) | `bootc upgrade`, reboot, Flatpak |
| [troubleshooting.md](troubleshooting.md) | Dual-variant matrix; greeter/session/launcher/themes |
| [screenshots.md](screenshots.md) | Capture ops index; assets under `docs/assets/` |

## Understanding the system

| Doc | Description |
|-----|-------------|
| [architecture.md](architecture.md) | bootc, skel caveat, theme store, two DE images |
| [contributor-notes.md](contributor-notes.md) | Lanes, Task Master PROTOCOL, where not to edit |

## Integration / media (not required to install)

| Doc | Description |
|-----|-------------|
| [../planning/integration/b-docs/screenshot-checklist.md](../planning/integration/b-docs/screenshot-checklist.md) | Planned shots, alt text, capture notes |
| [../planning/integration/b-docs/ACCURACY-AUDIT.md](../planning/integration/b-docs/ACCURACY-AUDIT.md) | Sources checked for handbook accuracy |
| [../planning/integration/b-docs/ISSUES.md](../planning/integration/b-docs/ISSUES.md) | Product gaps filed by docs lane |

## Image refs (quick)

```text
ghcr.io/neon798/hyprwave:latest
ghcr.io/neon798/hyprwave-cosmic:latest
```

> GHCR may be **private** (403) until package visibility is fixed — see INSTALL.

## Contributor build references

| Doc | Description |
|-----|-------------|
| [../CLAUDE.md](../CLAUDE.md) | Build commands and image layout |
| [../AGENTS.md](../AGENTS.md) | Packaging patterns |
| [../Justfile](../Justfile) | `just --list` |
| [../planning/taskmaster/PROTOCOL.md](../planning/taskmaster/PROTOCOL.md) | Multi-model task protocol |
