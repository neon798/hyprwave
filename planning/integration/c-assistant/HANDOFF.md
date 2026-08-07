# Model C handoff — Hyprwave Assistant

Wave 1 skeleton + **Wave 2 productization**. See also **HANDOFF-WAVE2.md** (Super+Shift+A, CLI, snippets).

## Delivered (dormant until integrator wires build.sh)

| Path | Role |
|------|------|
| `apps/hyprwave-assistant/` | Go module (Bubble Tea TUI + CLI) |
| `build_files/usr/share/hyprwave/assistant/` | catalog.toml + kb/*.md |
| `build_files/usr/share/applications/hyprwave-assistant.desktop` | menu entry |
| `planning/integration/c-assistant/*.snippet` | build + Containerfile hooks |

## Not touched (by design)

- `build_files/build.sh`, `Containerfile`, CI, skel, themes, duress/PAM

## Integrator checklist

1. Apply `Containerfile.snippet` (assistant-builder stage + COPY binary).
2. Apply `build.sh.snippet` (install data + desktop entry if not blanket-copied).
3. Optional: Super+Shift+A bind — exact lines in **HANDOFF-WAVE2.md** (skel edit by integrator).
4. `just build` both DE variants; launch from Ghostty / menu.
5. Optional README section from `README-blurb.md`.

## Validate without image

```bash
cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .
/tmp/hyprwave-assistant update --dry-run
```
