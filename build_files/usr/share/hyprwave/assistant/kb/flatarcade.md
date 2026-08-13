# FlatArcade vs Hyprwave Assistant

Both are terminal-friendly tools on Hyprwave. They **complement** each other; neither replaces the other.

## FlatArcade (full app store)

- Flathub **browser** / app store TUI: search, browse categories, install, remove, update.
- Best when you know an app name, want to explore the whole catalog, or manage apps outside the curated list.
- Launched from the menu, Super+A on Hyprland (skel), or `flatarcade` / Ghostty wrapper on the stock image.

Typical jobs:

- “Install Spotify / Discord / a niche IDE from Flathub”
- “What Flatpaks do I have, and which need updates?”
- “Remove an app I no longer use”

## Hyprwave Assistant (system companion)

- **Updater** — base image (`bootc`) + Flatpak updates with dry-run and double-confirm.
- **Installer** — short **curated** catalog (`catalog.toml`), not all of Flathub.
- **Knowledge Base** — how Hyprwave works (bootc, 11 themes, dual DE, Walker/hyprpaper, GHCR, …).
- Never reboots the host; stages base upgrades and tells you to reboot yourself.

Typical jobs:

- “Is my base image current? Stage an upgrade safely.”
- “Install LibreOffice / Steam / Bitwarden from the shortlist.”
- “How do I switch themes or rebase to COSMIC?”

## When to use which

| Goal | Tool |
|------|------|
| Browse all of Flathub | FlatArcade |
| One-click curated apps | Assistant → Installer |
| Update OS image (bootc) | Assistant → Updater |
| Learn the distro | Assistant → Knowledge Base |
| Update only Flatpaks | Either (Assistant or `flatpak update`) |
| Remove / manage arbitrary Flatpaks | FlatArcade or `flatpak` CLI |

## CLI quick reference

```bash
# Assistant — safe first
hyprwave-assistant update --dry-run
hyprwave-assistant list
hyprwave-assistant install libreoffice --dry-run
hyprwave-assistant kb flatarcade

# FlatArcade — full store UI (image-dependent launcher)
flatarcade
```

## Offline behavior

| Capability | Offline |
|------------|---------|
| Assistant KB browse/search | Works |
| Assistant catalog list / dry-run plans | Works |
| Assistant live update/install | Blocked with clear banner |
| FlatArcade remote search/install | Needs network |

## Design intent

Hyprwave prefers **immutable base + Flatpak apps**. FlatArcade is the day-to-day store. Assistant is the **safe systems + curated shortcuts + docs** surface so first-boot and maintenance stay simple without inventing package paths.
