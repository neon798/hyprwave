# Model C Wave 2 / C-W1-002 handoff — Hyprwave Assistant

## Branch

`lane/c-assistant` — production package surface for integrator drop-in.

## What shipped (summary)

- CLI: `status`, `update`, `install`, `list`, `kb`, `version` / `--version` with `--dry-run`, `--check`, `--yes --confirm`
- Double-confirm on all destructive paths (CLI + TUI Y×2)
- Offline probe with clear banner; KB + catalog remain usable offline
- Expanded `catalog.toml` + KB (including FlatArcade, theming, variants, **bootc-rebase**)
- Theme accent best-effort from `HYPRWAVE_THEME` / `~/.config/hyprwave/theme`
- Version **0.2.2** via ldflags; `-trimpath` in snippets
- Desktop entry + install layout documented in README / HANDOFF

## Integrator: image wiring (still dormant until applied)

1. Merge `Containerfile.snippet` → assistant-builder stage + `COPY` binary to `/usr/bin/hyprwave-assistant`
2. Merge `build.sh.snippet` → install `/usr/share/hyprwave/assistant` + desktop entry  
   **or** use the COPY block commented in the Containerfile snippet (binary **and** data + desktop in one flow)
3. Optional README: `README-blurb.md` + `RELEASE-NOTES-0.2.md`

## Integrator: Super+Shift+A keybind (skel — Model C must NOT edit skel)

**Exact line** for Hyprland bindings (e.g. `build_files/etc/skel/.config/hypr/bindings.conf` — apply via Model E / integrator):

```conf
# Hyprwave Assistant
bind = SUPER SHIFT, A, exec, ghostty -e hyprwave-assistant
```

Copy that `bind = …` line only; do not invent alternate modifiers unless product decides otherwise.

COSMIC: users can pin the desktop entry; no skel change required for basic menu launch.

Suggested Walker / menu: desktop file already sets  
`Exec=ghostty -e hyprwave-assistant`.

## Icon asset (optional)

Desktop currently uses `Icon=utilities-system-monitor` (generic, always present).  
Branded icon handoff: add `hyprwave-assistant.svg` (or PNG sizes) under hicolor, `gtk-update-icon-cache`, set `Icon=hyprwave-assistant`. Snippet comments show the install lines.

## Package deps

| Need | Why |
|------|-----|
| ghostty | Desktop/TUI host (`Exec=ghostty -e …`) |
| bootc | Base status/upgrade |
| flatpak | App updates/installs |
| Go (build stage only) | Compile assistant-builder |

## Post-install smoke

```bash
hyprwave-assistant --help
hyprwave-assistant --version
hyprwave-assistant kb
hyprwave-assistant list | head
hyprwave-assistant update --dry-run
```

## Validate without image

```bash
cd apps/hyprwave-assistant && go test ./... \
  && go build -trimpath -ldflags "-X main.version=0.2.2" -o /tmp/hyprwave-assistant .
/tmp/hyprwave-assistant version
/tmp/hyprwave-assistant update --dry-run
/tmp/hyprwave-assistant list | head
HYPRWAVE_ASSISTANT_DATA=../../build_files/usr/share/hyprwave/assistant \
  /tmp/hyprwave-assistant kb bootc-rebase | head
```

## Forbidden paths (still)

- Do not enable duress from this lane
- Do not edit production `build.sh` / `Containerfile` outside snippets
- Do not edit skel from this lane (keybind is handoff-only)
