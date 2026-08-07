# hyprwave-assistant

Go + Bubble Tea TUI and CLI for Hyprwave: **Updater**, **Installer**, **Knowledge Base**, **About**.

## Build

```bash
cd apps/hyprwave-assistant
go test ./...
go build -o hyprwave-assistant .
# release-ish:
CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -X main.version=0.2.0" -o hyprwave-assistant .
```

## CLI

```bash
hyprwave-assistant status [--check]
hyprwave-assistant update [--base|--flatpak|--all] [--dry-run|--check|--yes]
hyprwave-assistant install <id> [--dry-run|--yes]
hyprwave-assistant list [--source flathub|layer]
hyprwave-assistant kb [query|id]
hyprwave-assistant version
```

Mutating `update` / `install` require `--yes` (or use the TUI confirmations).  
**Never reboots** the host.

## Data

- `/usr/share/hyprwave/assistant/catalog.toml`
- `/usr/share/hyprwave/assistant/kb/*.md`

Override: `HYPRWAVE_ASSISTANT_DATA` or `--data DIR`.

## Theme

Best-effort accent from `HYPRWAVE_THEME` or `~/.config/hyprwave/theme`.

## TUI keys

| Key | Action |
|-----|--------|
| Tab / h l | Switch tabs |
| 1–4 | Jump tabs |
| r | Refresh status |
| b / f / a | Update base / Flatpaks / all (confirm) |
| Enter | Install / open article |
| / | Filter or search |
| q | Quit |
