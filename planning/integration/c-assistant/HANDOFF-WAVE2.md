# Model C Wave 2 handoff — Hyprwave Assistant

## Branch

`lane/c-assistant` — product quality for Assistant KB/catalog and package surface.

## What shipped (summary)

- CLI: `status`, `update`, `install`, `list`, `kb`, `version` / `--version` with `--dry-run`, `--check`, `--yes --confirm`
- Double-confirm on all destructive paths (CLI + TUI Y×2)
- Offline probe with clear banner; KB + catalog remain usable offline
- Expanded `catalog.toml` + KB (FlatArcade, theming, variants, bootc-rebase, **ghcr**, day-1 accuracy)
- Theme accent best-effort from `HYPRWAVE_THEME` / `~/.config/hyprwave/theme`
- Version **0.2.2** via ldflags; `-trimpath` in snippets
- Desktop entry + install layout documented in README / HANDOFF

## Image wiring (Wave 1 — applied on main)

Snippets under this directory were applied by the integrator. Local verification:

```bash
podman run --rm localhost/hyprwave:latest hyprwave-assistant --version
# hyprwave-assistant 0.2.2
```

Do not re-apply snippets unless a real regression appears.

## Super+Shift+A (skel — Model C must NOT edit skel)

On main Hyprland bindings:

```conf
bind = $mainMod SHIFT, A, exec, ghostty -e hyprwave-assistant
```

COSMIC: pin the desktop entry; no skel change required for basic menu launch.

## Day-1 KB claims (C-W2-001)

KB must match the shipped OS:

- Dual DE: `hyprwave` / `hyprwave-cosmic`
- Walker + hyprpaper on Hyprland (no Wofi/swaybg)
- 11 themes
- Duress **OFF** by default
- GHCR may be private
- Skel = new users only
- Super+Shift+A for Assistant on Hyprland

## Validate without image

```bash
bash planning/integration/c-assistant/smoke-host.sh
```

## Forbidden paths (still)

- Do not enable duress from this lane
- Do not edit production `build.sh` / `Containerfile` outside snippets (real hook bugs only)
- Do not edit skel from this lane
