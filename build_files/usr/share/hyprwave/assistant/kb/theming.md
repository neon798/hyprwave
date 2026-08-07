# Theming & Customization

Hyprwave ships a multi-theme store under `/usr/share/hyprwave/themes/`. Themes are whole-file packs (not partial palette fragments) so switches stay consistent across the stack.

## Switching themes

```bash
hyprwave-theme list
hyprwave-theme set <name>
```

On **Hyprland**, the switcher live-reloads compositor UI pieces (hypr look, waybar, walker, mako, ghostty, wallpaper) when those components are present.

On **COSMIC**, it copies theme `cosmic/config/` into `~/.config/cosmic/` and applies the wallpaper. You may need to reopen COSMIC settings panels or re-login for some keys to fully apply depending on session state.

Active theme pointer (Hyprland-oriented):

- `~/.config/hyprwave/theme` — absolute indirection symlink/file used by tools and Assistant accent detection

## Bundled themes (examples)

Synthwave (default), Retro Arcade, Cozy Harvest, Fjord Dark, Touge Drive, Vaporwave, Highway Haze, Lunar Pulse, Glitch Horizon, Arcade Rain, Verdant Haven — and any others listed by `hyprwave-theme list`.

## What a theme package contains

Each directory under `/usr/share/hyprwave/themes/<name>/` typically provides:

| Component | Role |
|-----------|------|
| `hypr/` | Compositor look / related fragments |
| `ghostty/` | Terminal palette |
| `waybar/` | Status bar styles |
| `walker/` | Launcher theme |
| `mako/` | Notification styling |
| `wallpapers/` | Desktop backgrounds |
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

Theme wallpapers live with the theme pack. System-shared art may also appear under `/usr/share/hyprwave/wallpapers` depending on image version. Hyprland wallpaper is typically driven by hyprpaper config linked from the theme.

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
