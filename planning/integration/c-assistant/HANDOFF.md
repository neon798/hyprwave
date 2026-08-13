# Model C HANDOFF — Hyprwave Assistant (freeze 0.2.2)

**Pre-merge freeze (C-W1-003).** Integrator applies in one pass. Do not invent alternate paths.

## Apply order

1. **Containerfile** — merge `Containerfile.snippet`
   - Stage `assistant-builder` (Go 1.23, `CGO_ENABLED=0`, `-trimpath`, `-ldflags "-s -w -X main.version=0.2.2"`)
   - Final image: `COPY --from=assistant-builder /out/hyprwave-assistant /usr/bin/hyprwave-assistant`
2. **build.sh** — merge `build.sh.snippet` **or** use the commented `COPY` block in the Containerfile snippet for data + desktop
3. **Skel keybind (Model E / integrator only — Model C does not edit skel):**

```conf
# Hyprwave Assistant
bind = SUPER SHIFT, A, exec, ghostty -e hyprwave-assistant
```

4. Build both DE variants; run host smoke (below) then image smoke after boot.

## Runtime paths (fixed)

```
/usr/bin/hyprwave-assistant
/usr/share/applications/hyprwave-assistant.desktop
/usr/share/hyprwave/assistant/catalog.toml
/usr/share/hyprwave/assistant/kb/*.md
```

Repo sources → targets:

| Source | Target |
|--------|--------|
| `apps/hyprwave-assistant/` (built binary) | `/usr/bin/hyprwave-assistant` |
| `build_files/usr/share/hyprwave/assistant/` | `/usr/share/hyprwave/assistant/` |
| `build_files/usr/share/applications/hyprwave-assistant.desktop` | `/usr/share/applications/…` |

Override data dir: `HYPRWAVE_ASSISTANT_DATA` or `--data DIR`.

## Package deps

| Dep | Role |
|-----|------|
| `ghostty` | Desktop `Exec=ghostty -e hyprwave-assistant` |
| `bootc` | Base status / upgrade |
| `flatpak` | App updates / curated installs |
| Go 1.23+ | **Build stage only** (not shipped) |

No exclusive extra packages beyond the image stack.

## Icon

Desktop uses `Icon=utilities-system-monitor`. Optional brand: hicolor `hyprwave-assistant` + set `Icon=` (see `build.sh.snippet` comments).

## Host smoke (no image)

```bash
bash planning/integration/c-assistant/smoke-host.sh
```

Must exit 0. Runs `go test ./...`, ldflags build, `--help`, `--version`, `kb`, `list`, `update --dry-run`.

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
- `README-blurb.md` — optional project README section
- Snippets only — **not** production `build.sh` / `Containerfile` edits from this lane

## Forbidden (Model C)

skel · production build.sh/Containerfile · duress/PAM · other models’ trees
