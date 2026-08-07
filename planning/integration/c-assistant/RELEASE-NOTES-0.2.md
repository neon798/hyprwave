# Release notes — hyprwave-assistant 0.2.x

Integrator CHANGELOG blurb for image / distro release notes.

## 0.2.2 (freeze C-W1-003)

- `planning/integration/c-assistant/smoke-host.sh` — host-side pre-merge smoke (test/build/CLI)
- HANDOFF one-pager freeze for integrator apply order

## 0.2.2 (C-W1-002)

**Hyprwave Assistant** is package-surface complete for a one-pass image integrate.

- Fixed install layout: `/usr/bin/hyprwave-assistant` + `/usr/share/hyprwave/assistant/{catalog.toml,kb/*.md}` + desktop entry
- Version stamped with `-trimpath` and `-ldflags "-X main.version=…"`
- CLI: `--version` / `version` / `help`; update & install require `--dry-run` or double-confirm (`--yes --confirm`)
- Offline-first: KB and catalog work without network; remote mutations blocked with a clear banner
- Expanded knowledge base (FlatArcade vs Assistant, theming, dual DE, bootc rebase user story)
- Snippets + HANDOFF for Super+Shift+A (`bind = SUPER SHIFT, A, exec, ghostty -e hyprwave-assistant`)

Suggested one-liner for image notes:

> **Hyprwave Assistant 0.2.2** — TUI/CLI for bootc + Flatpak updates, curated installs, and offline knowledge base. Launch from the menu or Super+Shift+A (when wired). Never auto-reboots.

## 0.2.1

- Double-confirm hardening, OnlineProbe stubs, coverage on catalog/kb/system
- KB: hyprpaper, variants, troubleshooting polish

## 0.2.0

- Initial CLI surface (`status` / `update` / `install` / `list` / `kb`)
- Theme accent, plan-based confirmations, expanded catalog

## Smoke after ship

```bash
hyprwave-assistant --help
hyprwave-assistant --version
hyprwave-assistant kb
hyprwave-assistant update --dry-run
```
