# Screenshot checklist (Wave 2 progress)

**Status:** no binary screenshots in-repo yet — **all captures remain TODO**.  
Do **not** block INSTALL/CHANGELOG on images. Capture after green VM first-boot.

Suggested resolution: **2560×1440** or **1920×1080**. Default theme **hyprwave**
unless the shot is a theme pack demo.

Progress legend: `TODO` | `CAPTURED` | `IN_README`

---

## Hyprland image

| # | Status | Shot | Suggested file | Alt text (for when captured) |
|---|--------|------|----------------|------------------------------|
| H1 | TODO | SDDM greeter | `docs/images/hyprland-sddm.png` | Hyprwave SDDM login screen with deep purple panel, chromatic HYPRWAVE title, user and password fields; no real password visible |
| H2 | TODO | Empty desktop | `docs/images/hyprland-desktop.png` | Hyprland desktop with synthwave wallpaper, Waybar along the edge, no open windows |
| H3 | TODO | Walker open | `docs/images/hyprland-walker.png` | Walker application launcher centered over the desktop showing a list of installed apps in synthwave colors |
| H4 | TODO | Ghostty | `docs/images/hyprland-ghostty.png` | Ghostty terminal window with a shell prompt on the Hyprwave desktop |
| H5 | TODO | Neonwolf | `docs/images/hyprland-neonwolf.png` | Neonwolf browser window with neutral start page; no personal accounts |
| H6 | TODO | Yazi in Ghostty | `docs/images/hyprland-yazi.png` | Yazi file manager TUI running inside Ghostty |
| H7 | TODO | FlatArcade | `docs/images/hyprland-flatarcade.png` | FlatArcade Flathub TUI with arcade-style chrome listing applications |
| H8 | TODO | Themes GUI | `docs/images/hyprland-themes-gui.png` | Hyprwave Themes GUI listing multiple theme packs with Apply control |
| H9 | TODO | Theme variety | `docs/images/hyprland-theme-vaporwave.png` (etc.) | Same desktop layout under vaporwave / fjord-dark / verdant-haven wallpapers and accents |
| H10 | TODO | Waybar crop | `docs/images/hyprland-waybar.png` | Close-up of Waybar modules: workspaces, network, clock |
| H11 | TODO | Mako notify | `docs/images/hyprland-mako.png` | Desktop with a Mako notification bubble matching the theme |

## COSMIC image

| # | Status | Shot | Suggested file | Alt text |
|---|--------|------|----------------|----------|
| C1 | TODO | cosmic-greeter | `docs/images/cosmic-greeter.png` | COSMIC greeter login screen on hyprwave-cosmic |
| C2 | TODO | COSMIC desktop | `docs/images/cosmic-desktop.png` | COSMIC desktop with Hyprwave wallpaper and dock favorites (Neonwolf, Files, Ghostty, FlatArcade, Settings) |
| C3 | TODO | Ghostty + FlatArcade | `docs/images/cosmic-companions.png` | Ghostty and FlatArcade open on COSMIC |
| C4 | TODO | Theme switcher | `docs/images/cosmic-themes.png` | Hyprwave Themes UI or desktop after theme apply on COSMIC |
| C5 | TODO | Cosmic Settings | `docs/images/cosmic-settings.png` | COSMIC Settings reflecting Hyprwave accent colors |

## Optional motion

| # | Status | Asset | Alt / caption |
|---|--------|-------|---------------|
| M1 | TODO | Short GIF/WebM | Screen recording: open Walker, launch terminal, switch theme with Super+Shift+T |
| M2 | TODO | Install flow | Terminal showing `bootc switch` success, then greeter (no secrets) |

---

## Wiring into docs (when files exist)

1. Place PNGs under `docs/images/`.  
2. Reference from [README.md](../../../README.md) and [docs/README.md](../../../docs/README.md)
   with the alt text above.  
3. Flip Status → `CAPTURED` then `IN_README`.  
4. Until then, keep prose-only install docs (current state).

## Capture tips

- Fresh VM user so `/etc/skel` defaults match docs.  
- Hide host-specific names, email, bookmarks.  
- Hyprland region capture: Super+Shift+S → `~/Pictures`.  
- Note scale/resolution in a one-line caption if UI differs from bare metal.  
- Prefer lostless PNG for UI chrome; JPEG only for large wallpapers if needed.

## Wave 2 docs progress (this lane)

| Deliverable | Done |
|-------------|------|
| Checklist + alt-text table | yes |
| Actual screenshot files | **no** (not blocking) |
| README image embeds | **no** (wait for files) |
