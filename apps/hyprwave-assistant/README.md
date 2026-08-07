# hyprwave-assistant

Go + Bubble Tea TUI and CLI for Hyprwave: **Updater**, **Installer**, **Knowledge Base**, **About**.

## Build & test

```bash
cd apps/hyprwave-assistant
go test ./...
go test ./internal/catalog ./internal/kb ./internal/system -cover
go build -o hyprwave-assistant .
# release-ish static binary:
CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -X main.version=0.2.1" -o hyprwave-assistant .
```

Unit tests must not perform real network I/O (`OnlineProbe` is stubbed via `OfflineForTests` / `OnlineForTests`).

## CLI

```bash
hyprwave-assistant                         # TUI
hyprwave-assistant status [--check]
hyprwave-assistant update [--base|--flatpak|--all] [--dry-run|--check|--yes --confirm]
hyprwave-assistant install <id> [--dry-run|--yes --confirm]
hyprwave-assistant list [--source flathub|layer]
hyprwave-assistant kb [query|id]
hyprwave-assistant version
hyprwave-assistant help
```

### Safety

| Path | Dry-run | Double confirm |
|------|---------|----------------|
| `update` (mutate) | `--dry-run` | `--yes` **and** `--confirm` |
| `install` (mutate) | `--dry-run` | `--yes` **and** `--confirm` |
| TUI update/install | plan shown | press **Y twice** |

**Never reboots** the host. Base upgrades only stage a deployment.

### Offline

- **Works offline:** KB browse/search, catalog list/filter, dry-run plans, status of local tools
- **Needs network:** live `bootc upgrade`, `flatpak update/install`
- Updater shows a clear **OFFLINE / cannot reach** banner when connectivity probe fails

## Environment & data

| Variable / flag | Purpose |
|-----------------|---------|
| `HYPRWAVE_ASSISTANT_DATA` | Dir with `catalog.toml` + `kb/` |
| `--data DIR` | Same, CLI flag |
| `HYPRWAVE_THEME` | Theme name for TUI accent (best-effort) |

Default search order includes `/usr/share/hyprwave/assistant` and repo `build_files/usr/share/hyprwave/assistant`.

Files:

- `catalog.toml` — curated installer entries (Flathub IDs validated in tests)
- `kb/*.md` — knowledge base articles

## Theme

Accent from `HYPRWAVE_THEME` or `~/.config/hyprwave/theme` (file or symlink). Unknown themes keep classic synthwave.

## TUI keys

| Key | Action |
|-----|--------|
| Tab / h l | Switch tabs |
| 1–4 | Jump tabs |
| r | Refresh status |
| b / f / a | Update base / Flatpaks / all (double-confirm) |
| Enter | Install / open article |
| / | Filter or search |
| q | Quit |

## Image integration

Dormant until integrator applies `planning/integration/c-assistant/` snippets. Keybind Super+Shift+A is documented in `HANDOFF-WAVE2.md` (do not edit skel from this package).
