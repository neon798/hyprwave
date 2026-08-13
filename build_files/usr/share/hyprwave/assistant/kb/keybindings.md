# Workflow & Keybindings (Hyprland)

Defaults for the Hyprland image (skel `bindings.conf` for **new users**). COSMIC uses the COSMIC shell shortcuts instead.

## Essentials

| Keys | Action |
|------|--------|
| Super + Return / Super + T | Terminal (Ghostty) |
| Super + D / Super + Space | Walker app launcher |
| Super + R | Walker runner mode |
| Super + B | Neonwolf browser |
| Super + E | Yazi (in Ghostty) |
| Super + A | FlatArcade (in Ghostty) |
| Super + Shift + A | **Hyprwave Assistant** (in Ghostty) |
| Super + Shift + T | Theme switcher GUI |
| Super + Q | Close window |
| Super + F | Fullscreen |
| Super + Shift + E | Exit Hyprland session |
| Super + Shift + L | Lock session |

Exact binds live in `~/.config/hypr/bindings.conf` (from skel on first login). Existing users keep their old binds after an image upgrade.

## Core apps

- **Walker** — application launcher (elephant plugins supply results).
- **Ghostty** — default terminal.
- **Yazi** — file manager inside the terminal (not a GTK file manager).
- **FlatArcade** — browse/install Flathub apps in a TUI.
- **Hyprwave Assistant** — updates, curated installs, knowledge base (**Super+Shift+A**).

## Session helpers

- **hyprlock / hypridle** — lock screen and idle behavior.
- **hyprpaper** — wallpapers from the active theme.
- **mako** — notifications.
- **waybar** — status bar.

## Customizing

Edit fragments under `~/.config/hypr/` (not only `hyprland.conf` — it sources the others). Changes apply after reload (`hyprctl reload`) or logout.
