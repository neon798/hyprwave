# Walker Launcher

Walker is the Hyprland app launcher (not used on COSMIC, which has its own shell launcher).

## Keys (defaults)

| Keys | Action |
|------|--------|
| Super + D / Super + Space | Open Walker |
| Super + R | Runner mode (`walker --prefix ">"`) |
| XF86Search | Open Walker (if bound) |

## How results appear

Walker 2.x has **no built-in providers**. Data comes from **elephant** plugins (desktop apps, calc, files, websearch, …). The elephant service must be running (autostart).

## Themes

Walker styling is part of the Hyprwave theme pack (`hyprwave-theme set …`). Synthwave defaults live under the active theme’s walker files.

## Icons missing?

GTK may read a stale hicolor cache. Image builds refresh it; on a live system:

```bash
gtk-update-icon-cache -f /usr/share/icons/hicolor
```

## Restart

```bash
systemctl --user restart app-walker@autostart.service
# or relaunch from a terminal: walker
```

## FlatArcade / Assistant

- **Walker** launches apps already installed.
- **FlatArcade** browses Flathub.
- **Hyprwave Assistant** installs a short curated list + updates the OS.
