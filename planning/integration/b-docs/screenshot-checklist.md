# Screenshot checklist (Wave 2 / marketing)

Do **not** block INSTALL.md or CHANGELOG.md on capturing these. Capture after a green
VM first-boot (both variants preferred). Store final assets under a public path the
integrator chooses (e.g. `docs/images/` or the GitHub repo social preview).

Suggested resolution: **2560×1440** or **1920×1080**. Prefer the default **hyprwave**
theme unless the shot is specifically about another pack.

## Hyprland image

| # | Shot | Notes |
|---|------|--------|
| H1 | SDDM greeter | Synthwave theme, clock, login card — no real password on screen |
| H2 | Empty desktop | Wallpaper + Waybar + clean layout |
| H3 | Walker open | Super+D; a few apps visible; synthwave CSS |
| H4 | Ghostty | Terminal with prompt; optional `neofetch`/`fastfetch` if installed |
| H5 | Neonwolf | Browser chrome; avoid personal accounts |
| H6 | Yazi in Ghostty | Super+E |
| H7 | FlatArcade | Super+A or desktop entry |
| H8 | Hyprwave Themes GUI | Super+Shift+T; list of 11 themes |
| H9 | Theme variety | 2–3 desktops: e.g. vaporwave, fjord-dark, verdant-haven |
| H10 | Waybar detail | Crop of modules (workspaces, network, clock) |
| H11 | Notification (Mako) | Trigger a test notify if useful |

## COSMIC image

| # | Shot | Notes |
|---|------|--------|
| C1 | cosmic-greeter | Login screen |
| C2 | COSMIC desktop | Dock favorites + Hyprwave wallpaper |
| C3 | Ghostty + FlatArcade | Shared companions |
| C4 | Theme switcher | GUI or after `hyprwave-theme set …` |
| C5 | Cosmic Settings | Optional; shows stock COSMIC chrome with our colors if applied |

## Optional motion

| # | Asset | Notes |
|---|-------|--------|
| M1 | Short GIF/WebM | Open Walker → launch terminal → switch theme |
| M2 | Install flow | `bootc switch` terminal + reboot + greeter (privacy-safe) |

## Filename convention (suggested)

```
docs/images/hyprland-sddm.png
docs/images/hyprland-desktop.png
docs/images/hyprland-walker.png
docs/images/hyprland-themes-gui.png
docs/images/cosmic-desktop.png
…
```

Wire paths into README / INSTALL only when files exist (or mark `TODO: screenshot`).

## Capture tips

- Use a fresh VM user so skel defaults match docs.
- Hide host bookmarks, email, and unique machine names.
- For Hyprland region shots: Super+Shift+S → `~/Pictures`.
- Note GPU/VM resolution in a one-line caption if UI scale differs from bare metal.
