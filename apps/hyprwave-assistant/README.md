# hyprwave-assistant

Go + Bubble Tea TUI and CLI for Hyprwave: **Updater**, **Installer**, **Knowledge Base**, **About**.

Version default in source: **0.2.2** (override with `-ldflags "-X main.version=…"`).

## Build & test

```bash
cd apps/hyprwave-assistant
go test ./...
go test ./internal/catalog ./internal/kb ./internal/system -cover
go build -o hyprwave-assistant .
# release-ish static binary (integrator uses this shape):
CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -X main.version=0.2.2" -o hyprwave-assistant .
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
hyprwave-assistant --version
hyprwave-assistant help
hyprwave-assistant --help
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
- Updater/About show a clear **OFFLINE / cannot reach** banner when connectivity probe fails

## Install layout (runtime)

Integrator installs a **fixed tree**. The binary resolves data in this order:

1. `--data DIR`
2. `HYPRWAVE_ASSISTANT_DATA`
3. `/usr/share/hyprwave/assistant` ← **production default**
4. Repo-relative `build_files/usr/share/hyprwave/assistant` (dev)
5. `testdata` / beside the executable

### Production tree (after image integrate)

```
/usr/bin/hyprwave-assistant
/usr/share/applications/hyprwave-assistant.desktop
/usr/share/hyprwave/assistant/
  catalog.toml          # curated installer entries
  kb/
    *.md                # knowledge base articles (id = filename stem)
```

Inventoried share tree (repo → image):

- `build_files/usr/share/applications/hyprwave-assistant.desktop`
- `build_files/usr/share/hyprwave/assistant/catalog.toml`
  - `kb/bootc-rebase.md`
  - `kb/duress.md`
  - `kb/extending.md`
  - `kb/first-boot.md`
  - `kb/flatarcade.md`
  - `kb/hyprpaper.md`
  - `kb/keybindings.md`
  - `kb/philosophy.md`
  - `kb/theming.md`
  - `kb/troubleshooting.md`
  - `kb/updates.md`
  - `kb/variants.md`
  - `kb/walker.md`

Repo sources that map 1:1:

| Source | Install target |
|--------|----------------|
| `apps/hyprwave-assistant/` (Go build) | `/usr/bin/hyprwave-assistant` |
| `build_files/usr/share/hyprwave/assistant/` | `/usr/share/hyprwave/assistant/` |
| `build_files/usr/share/applications/hyprwave-assistant.desktop` | `/usr/share/applications/…` |

See `planning/integration/c-assistant/` for `Containerfile.snippet` + `build.sh.snippet` + **`smoke-host.sh`** (one-pass wire-up + freeze smoke).

### Environment & flags

| Variable / flag | Purpose |
|-----------------|---------|
| `HYPRWAVE_ASSISTANT_DATA` | Dir with `catalog.toml` + `kb/` |
| `--data DIR` | Same, CLI flag |
| `HYPRWAVE_THEME` | Theme name for TUI accent (best-effort) |

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
