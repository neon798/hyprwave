# Model C Wave 2 handoff — Hyprwave Assistant

## Branch

`lane/c-assistant` — continues Wave 1; productionizes CLI + robustness.

## What changed overnight

- CLI: `status`, `update`, `install`, `list`, `kb`, `version` with `--dry-run`, `--check`, `--yes`
- Command planners + classified errors (privileges / offline)
- Never forces reboot; confirmations show planned commands
- Expanded `catalog.toml` (verified Flathub IDs) + new KB articles (first-boot, walker, extending)
- Theme accent best-effort from `HYPRWAVE_THEME` / `~/.config/hyprwave/theme`
- Stronger `go test` coverage; version `0.2.0`

## Integrator: image wiring (still dormant until applied)

1. Merge `Containerfile.snippet` → assistant-builder stage + `COPY` binary to `/usr/bin/hyprwave-assistant`
2. Merge `build.sh.snippet` → install `/usr/share/hyprwave/assistant` + desktop entry
3. Optional README blurb: `README-blurb.md`

## Integrator: Super+Shift+A keybind (skel — Model C must NOT edit skel)

Add to Hyprland bindings (e.g. `build_files/etc/skel/.config/hypr/bindings.conf`):

```conf
# Hyprwave Assistant
bind = SUPER SHIFT, A, exec, ghostty -e hyprwave-assistant
```

COSMIC: users can pin the desktop entry; no skel change required for basic menu launch.

Suggested Walker / menu: desktop file already sets  
`Exec=ghostty -e hyprwave-assistant`.

## Validate without image

```bash
cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .
/tmp/hyprwave-assistant version
/tmp/hyprwave-assistant update --dry-run
/tmp/hyprwave-assistant list | head
HYPRWAVE_ASSISTANT_DATA=../../build_files/usr/share/hyprwave/assistant \
  /tmp/hyprwave-assistant kb philosophy | head
```

## Forbidden paths (still)

- Do not enable duress from this lane
- Do not edit production `build.sh` / `Containerfile` outside snippets
- Do not edit skel from this lane (keybind is handoff-only)
