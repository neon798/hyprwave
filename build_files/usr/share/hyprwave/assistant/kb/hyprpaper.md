# Wallpapers with hyprpaper

Hyprland images use **hyprpaper** for wallpapers (not swaybg).

## How it fits

- Active theme supplies wallpaper paths under the theme store.
- `hyprpaper` is started from Hyprland autostart / config.
- Switching themes with `hyprwave-theme set <name>` reloads wallpaper for the new pack.

## Config location

User config typically:

```text
~/.config/hypr/hyprpaper.conf
```

Skel defaults ship for **new** users only. Existing homes keep their file until you update it or re-apply a theme.

## Common operations

```bash
# After editing hyprpaper.conf
hyprctl hyprpaper reload   # if supported by your hyprpaper build
# or restart the session / hyprpaper process
```

## COSMIC variant

COSMIC uses its own wallpaper settings (vendor keys under the theme’s `cosmic/config/` and `hyprwave-theme`). hyprpaper is a Hyprland-stack tool.

## Offline note

Wallpaper files live on the local image. Theme switching does not need network.
