# Model C HANDOFF — Hyprwave Assistant (0.2.2 image-hooked)

**Status (C-W2-001):** Assistant is **integrated on main** and present in local T8 image builds. Lane keeps data/KB quality; do not re-open dormant wiring unless a real hook bug appears.

## Image verification (local T8)

```text
Image:    localhost/hyprwave:latest
Binary:   /usr/bin/hyprwave-assistant  (usr-merge may also list /usr/sbin)
Version:  0.2.2
Data:     /usr/share/hyprwave/assistant/{catalog.toml,kb/*.md}
Desktop:  /usr/share/applications/hyprwave-assistant.desktop
Themes:   11 under /usr/share/hyprwave/themes/
```

Probe:

```bash
podman run --rm localhost/hyprwave:latest hyprwave-assistant --version
# expect: hyprwave-assistant 0.2.2
```

## Apply order (0.2.2 hooks)

Integrator one-pass (snippets only — Model C does **not** edit live
`Containerfile` / `build.sh`). Order:

1. **`Containerfile.snippet`** — `FROM … AS assistant-builder`;
   `ASSISTANT_VERSION=0.2.2`; `go build -trimpath` +
   `-ldflags="-s -w -X main.version=${ASSISTANT_VERSION}"`;
   `COPY --from=assistant-builder /out/hyprwave-assistant /usr/bin/hyprwave-assistant`.
2. **`build.sh.snippet`** — install `/usr/share/hyprwave/assistant/`
   (`catalog.toml` + `kb/*.md`) and
   `/usr/share/applications/hyprwave-assistant.desktop`; optional
   fallback copy of the binary to `/usr/bin/hyprwave-assistant`.
3. **Super+Shift+A** — **Model E / integrator only** (Hyprland skel bind).
   This lane must not edit skel. COSMIC: pin the desktop entry.

Selftest (fail-closed on hook drift):

```bash
bash planning/integration/c-assistant/snippet-selftest.sh
```

## Runtime paths (fixed)

```
/usr/bin/hyprwave-assistant
/usr/share/applications/hyprwave-assistant.desktop
/usr/share/hyprwave/assistant/catalog.toml
/usr/share/hyprwave/assistant/kb/*.md
```

| Source | Target |
|--------|--------|
| `apps/hyprwave-assistant/` (built binary) | `/usr/bin/hyprwave-assistant` |
| `build_files/usr/share/hyprwave/assistant/` | `/usr/share/hyprwave/assistant/` |
| `build_files/usr/share/applications/hyprwave-assistant.desktop` | `/usr/share/applications/…` |

Override data dir: `HYPRWAVE_ASSISTANT_DATA` or `--data DIR`.

## Skel keybind (do not edit skel from this lane)

Already on main Hyprland bindings:

```conf
bind = $mainMod SHIFT, A, exec, ghostty -e hyprwave-assistant
```

COSMIC: pin the desktop entry from the menu.

## Package deps

| Dep | Role |
|-----|------|
| `ghostty` | Desktop `Exec=ghostty -e hyprwave-assistant` |
| `bootc` | Base status / upgrade |
| `flatpak` | App updates / curated installs |
| Go 1.23+ | **Build stage only** (not shipped) |

## Host smoke (no image)

```bash
bash planning/integration/c-assistant/smoke-host.sh
```

Must exit 0. Runs `go test ./...`, ldflags build, `--help`, `--version`, `kb`, `list`, `update --dry-run`, and `snippet-selftest.sh`.

## Post-image smoke

```bash
hyprwave-assistant --help
hyprwave-assistant --version
hyprwave-assistant kb
hyprwave-assistant list | head
hyprwave-assistant update --dry-run
```

## Safety (do not regress)

- Mutations need `--dry-run` **or** `--yes --confirm` (TUI: Y twice)
- Never reboots the host
- Offline: KB + catalog work; remote update/install blocked

## Related

- `HANDOFF-WAVE2.md` — CLI detail / dual-DE notes
- `RELEASE-NOTES-0.2.md` — CHANGELOG blurb
- Snippets remain under this tree for reference; production wiring is already on main

## Forbidden (Model C)

skel · production build.sh/Containerfile (except real hook bug via snippets) · duress/PAM · other models’ trees
