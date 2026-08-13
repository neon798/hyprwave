# Workflow & Keybindings (Hyprland)

Defaults for the Hyprland image. COSMIC uses the COSMIC shell shortcuts instead.

## Essentials

| Keys | Action |
|------|--------|
| Super + Enter | Terminal (Ghostty) |
| Super + D / Super + Space | Walker app launcher |
| Super + R | Walker runner mode |
| Super + Q | Close window |
| Super + F | Fullscreen |
| Super + Shift + T | Theme switcher (if bound) |

Exact binds live in `~/.config/hypr/bindings.conf` (from skel on first login).

## Core apps

- **Walker** — application launcher (elephant plugins supply results).
- **Ghostty** — default terminal.
- **Yazi** — file manager inside the terminal.
- **FlatArcade** — browse/install Flathub apps in a TUI.
- **Hyprwave Assistant** — updates, curated installs, knowledge base.

## Session helpers

- **hyprlock / hypridle** — lock screen and idle behavior.
- **hyprpaper** — wallpapers from the active theme.
- **mako** — notifications.
- **waybar** — status bar.

## Customizing

Edit fragments under `~/.config/hypr/` (not only `hyprland.conf` — it sources the others). Changes apply after reload (`hyprctl reload`) or logout.
