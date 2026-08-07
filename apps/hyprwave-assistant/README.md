# hyprwave-assistant

Go + Bubble Tea TUI for Hyprwave: **Updater**, **Installer**, **Knowledge Base**, **About**.

## Build

```bash
cd apps/hyprwave-assistant
go test ./...
go build -o hyprwave-assistant .
```

Static-ish release build:

```bash
CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -X main.version=0.1.0" -o hyprwave-assistant .
```

## Data

Runtime assets (not compiled in):

- `/usr/share/hyprwave/assistant/catalog.toml`
- `/usr/share/hyprwave/assistant/kb/*.md`

Override:

```bash
export HYPRWAVE_ASSISTANT_DATA=/path/to/assistant
# or
./hyprwave-assistant --data /path/to/assistant
```

In a git checkout, the binary also probes
`build_files/usr/share/hyprwave/assistant`.

## Keys

| Key | Action |
|-----|--------|
| Tab / h l | Switch tabs |
| 1–4 | Jump tabs |
| r | Refresh status |
| b / f / a | Update base / Flatpaks / all (confirm) |
| Enter | Install / open article |
| / | Filter or search |
| q | Quit |

## CLI

```bash
hyprwave-assistant status
hyprwave-assistant version
```
