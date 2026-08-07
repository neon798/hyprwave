# Model C handoff — Hyprwave Assistant

Wave 1 skeleton + Wave 2 productization + **C-W1-002 package surface** (0.2.2).  
See also **HANDOFF-WAVE2.md** (Super+Shift+A, CLI, smoke) and **RELEASE-NOTES-0.2.md**.

## Delivered (dormant until integrator wires build)

| Path | Role |
|------|------|
| `apps/hyprwave-assistant/` | Go module (Bubble Tea TUI + CLI), version 0.2.2 |
| `build_files/usr/share/hyprwave/assistant/` | `catalog.toml` + `kb/*.md` |
| `build_files/usr/share/applications/hyprwave-assistant.desktop` | menu entry |
| `planning/integration/c-assistant/*.snippet` | build + Containerfile hooks |
| `planning/integration/c-assistant/RELEASE-NOTES-0.2.md` | CHANGELOG blurb |

## Runtime layout (do not invent alternate paths)

```
/usr/bin/hyprwave-assistant
/usr/share/applications/hyprwave-assistant.desktop
/usr/share/hyprwave/assistant/catalog.toml
/usr/share/hyprwave/assistant/kb/*.md
```

## Not touched (by design)

- `build_files/build.sh`, `Containerfile`, CI, skel, themes, duress/PAM

## Integrator checklist (one pass)

1. Apply `Containerfile.snippet` (assistant-builder + COPY binary; `-trimpath` + ldflags version).
2. Apply `build.sh.snippet` **or** COPY data + desktop as commented in Containerfile snippet.
3. Optional: Super+Shift+A bind — exact line in **HANDOFF-WAVE2.md** (skel edit by integrator / Model E).
4. Optional icon: ship SVG/PNG as `hyprwave-assistant` under hicolor; desktop currently uses `utilities-system-monitor`.
5. `just build` both DE variants; smoke commands below.
6. Optional README section from `README-blurb.md` / release notes.

## Package deps

- **Required at runtime for full features:** `bootc` (base updates), `flatpak` (apps), `ghostty` (desktop Exec host for TUI).
- **Build-time only:** Go 1.23+ toolchain in `assistant-builder` stage (does not ship).
- No exclusive extra dnf packages beyond the image’s existing stack.

## Post-install smoke

```bash
hyprwave-assistant --help
hyprwave-assistant --version
hyprwave-assistant version
hyprwave-assistant kb
hyprwave-assistant list | head
hyprwave-assistant update --dry-run
```

## Validate without image

```bash
cd apps/hyprwave-assistant && go test ./... \
  && go build -trimpath -ldflags "-X main.version=test" -o /tmp/hyprwave-assistant .
/tmp/hyprwave-assistant update --dry-run
```
