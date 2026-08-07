# Theming & Customization

Hyprwave ships a multi-theme store under `/usr/share/hyprwave/themes/`.

## Switching themes

```bash
hyprwave-theme list
hyprwave-theme set <name>
```

On **Hyprland**, the switcher live-reloads compositor UI pieces (hypr, waybar, walker, mako, ghostty, wallpaper).

On **COSMIC**, it copies theme `cosmic/config/` into `~/.config/cosmic/` and sets the wallpaper.

## Bundled themes (examples)

Synthwave (default), Retro Arcade, Cozy Harvest, Fjord Dark, Touge Drive, Vaporwave, Highway Haze, Lunar Pulse, Glitch Horizon, Arcade Rain, Verdant Haven — and any others under the themes store.

## What a theme package contains

Each theme directory typically provides whole-file components:

- Hyprland look / wallpaper
- Ghostty palette
- Waybar + Walker + Mako styles
- Optional COSMIC vendor keys and SDDM assets

## Skel vs your home

`/etc/skel` defaults apply to **new users only**. Changing image skel does not rewrite an existing `~/.config`. Theme switching updates the live user config via `hyprwave-theme`.

## Wallpapers

Theme wallpapers live with the theme pack. System-shared art may also appear under `/usr/share/hyprwave/wallpapers` depending on image version.
