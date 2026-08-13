# Theming & Customization

Hyprwave ships **11** theme packs under `/usr/share/hyprwave/themes/`. Themes are whole-file packs (not partial palette fragments) so switches stay consistent across the stack.

## Switching themes

```bash
hyprwave-theme list
hyprwave-theme set <name>
```

On **Hyprland**, Super+Shift+T opens the theme GUI (`hyprwave-theme-gui`). The switcher live-reloads compositor UI pieces (hypr look, waybar, walker, mako, ghostty, wallpaper) when those components are present.

On **COSMIC**, it copies theme `cosmic/config/` into `~/.config/cosmic/` and applies the wallpaper. You may need to reopen COSMIC settings panels or re-login for some keys to fully apply depending on session state.

Active theme pointer:

- `~/.config/hyprwave/theme` — absolute indirection symlink/file used by tools and Assistant accent detection

## The 11 bundled themes

| Name | Character |
|------|-----------|
| **hyprwave** (default) | Classic synthwave |
| retro-arcade | 80s arcade cabinets |
| cozy-harvest | Warm earthy farm life |
| fjord-dark | Clean cold nordic |
| touge-drive | Night mountain racing |
| vaporwave | 80s/90s vapor |
| highway-haze | Misty neon drive |
| lunar-pulse | Dreamy moonlit |
| glitch-horizon | Glitchy retro future |
| arcade-rain | Rainy neon arcade |
| verdant-haven | Immersive nature |

Confirm with `hyprwave-theme list` (must match these 11 names).

## What a theme package contains

Each directory under `/usr/share/hyprwave/themes/<name>/` typically provides:

| Component | Role |
|-----------|------|
| `hypr/` | Compositor look / related fragments |
| `ghostty/` | Terminal palette |
| `waybar/` | Status bar styles |
| `walker/` | Launcher theme (Hyprland) |
| `mako/` | Notification styling |
| `wallpapers/` | Desktop backgrounds (hyprpaper on Hyprland) |
| `cosmic/config/` | COSMIC vendor-default keys (COSMIC variant) |
| optional `sddm/` | Greeter assets when present |

## Skel vs your home

`/etc/skel` defaults apply to **new users only**. Changing image skel does **not** rewrite an existing `~/.config`.

- New user → gets skel defaults + theme indirection
- Existing user → use `hyprwave-theme set …` to refresh live config pieces
- Hand-edited files under `~/.config` may be overwritten by the switcher for theme-owned paths

## Assistant accent

Hyprwave Assistant reads theme name best-effort from:

1. `HYPRWAVE_THEME` environment variable
2. `~/.config/hyprwave/theme` (symlink target or file content)

Unknown names keep the classic synthwave palette (pink / cyan / purple). Accent only affects the TUI chrome, not the whole desktop.

## Wallpapers

Theme wallpapers live with the theme pack. Hyprland wallpaper is driven by **hyprpaper** (see `hyprpaper` article). COSMIC uses its own background keys.

## Troubleshooting themes

| Symptom | Check |
|---------|-------|
| Theme “set” but UI unchanged | Confirm Hyprland vs COSMIC; re-login; verify `hyprwave-theme list` includes the name |
| Walker / bar look stale | Restart waybar / elephant / walker user services if present |
| Wrong TUI accent in Assistant | Export `HYPRWAVE_THEME=<name>` or fix `~/.config/hyprwave/theme` |
| COSMIC looks Fedora-default | Ensure theme has `cosmic/config/` and re-run `hyprwave-theme set` |

## Related articles

- `variants` — dual DE differences
- `walker` — launcher on Hyprland
- `hyprpaper` — wallpaper daemon notes
- `bootc-rebase` — switching image variants (not a theme switch)
