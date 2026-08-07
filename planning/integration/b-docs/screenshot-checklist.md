# Screenshot checklist (handbook media)

**Status:** no binary screenshots in-repo — **all captures remain TODO**.  
Do **not** block INSTALL or the handbook on images.

Suggested resolution: **2560×1440** or **1920×1080**. Default theme **hyprwave**
unless the shot demos another pack.

Progress legend: `TODO` | `CAPTURED` | `IN_README`

---

## Hyprland image

| # | Status | Shot | Purpose | Suggested file | Alt text | Capture notes |
|---|--------|------|---------|----------------|----------|---------------|
| H1 | TODO | SDDM greeter | Prove first-boot brand | `docs/images/hyprland-sddm.png` | Hyprwave SDDM login: deep purple panel, chromatic HYPRWAVE title, user/password fields; no real password | Boot Hyprland image; before login; crop cleanly |
| H2 | TODO | Empty desktop | Default skel look | `docs/images/hyprland-desktop.png` | Hyprland desktop with synthwave wallpaper and Waybar; no open windows | Fresh user; wait for waybar/hyprpaper |
| H3 | TODO | Walker open | Launcher is Walker | `docs/images/hyprland-walker.png` | Walker launcher centered listing apps in synthwave CSS | Super+D; type nothing or one letter |
| H4 | TODO | Ghostty | Default terminal | `docs/images/hyprland-ghostty.png` | Ghostty terminal with shell prompt on Hyprwave | Super+Return |
| H5 | TODO | Neonwolf | Default browser | `docs/images/hyprland-neonwolf.png` | Neonwolf browser with neutral page; no personal accounts | Super+B |
| H6 | TODO | Yazi | Default file manager | `docs/images/hyprland-yazi.png` | Yazi TUI inside Ghostty | Super+E |
| H7 | TODO | FlatArcade | App install path | `docs/images/hyprland-flatarcade.png` | FlatArcade Flathub TUI arcade chrome | Super+A |
| H8 | TODO | Themes GUI | Theme product | `docs/images/hyprland-themes-gui.png` | Hyprwave Themes GUI listing packs | Super+Shift+T |
| H9 | TODO | Theme variety | Multi-pack proof | `docs/images/hyprland-theme-*.png` | Desktop under vaporwave / fjord-dark / verdant-haven | `hyprwave-theme set …` then H2-style shot |
| H10 | TODO | Waybar crop | Bar modules | `docs/images/hyprland-waybar.png` | Close-up Waybar: workspaces, network, clock | Region capture Super+Shift+S |
| H11 | TODO | Mako | Notifications | `docs/images/hyprland-mako.png` | Mako notification bubble themed | `notify-send 'Hyprwave' 'Test'` if available |

## COSMIC image

| # | Status | Shot | Purpose | Suggested file | Alt text | Capture notes |
|---|--------|------|---------|----------------|----------|---------------|
| C1 | TODO | cosmic-greeter | Greeter differs from SDDM | `docs/images/cosmic-greeter.png` | cosmic-greeter login on hyprwave-cosmic | Boot cosmic image |
| C2 | TODO | COSMIC desktop | Dock + wallpaper | `docs/images/cosmic-desktop.png` | COSMIC desktop Hyprwave wallpaper and dock favorites | Fresh session |
| C3 | TODO | Companions | Shared apps | `docs/images/cosmic-companions.png` | Ghostty and FlatArcade on COSMIC | From dock/launcher |
| C4 | TODO | Theme switcher | Themes on COSMIC | `docs/images/cosmic-themes.png` | Theme UI or post-apply desktop | `hyprwave-theme-gui` |
| C5 | TODO | Settings | Accent identity | `docs/images/cosmic-settings.png` | Cosmic Settings with Hyprwave colors | Optional |

## Optional motion

| # | Status | Asset | Purpose | Alt / caption | Capture notes |
|---|--------|-------|---------|---------------|---------------|
| M1 | TODO | GIF/WebM | Walker → terminal → theme | Recording of Super+D, Super+Return, Super+Shift+T | Keep under ~15s |
| M2 | TODO | Install flow | bootc path | Terminal `bootc switch` success then greeter | No tokens/passwords |

---

## Capture commands (Hyprland skel)

From `build_files/etc/skel/.config/hypr/bindings.conf`:

| Goal | Input |
|------|--------|
| Region → `~/Pictures` | Super+Shift+S (`hyprshot -m region -o ~/Pictures`) |
| Region → clipboard | Super+S |
| Full output → file | Super+Ctrl+Shift+S |
| Walker | Super+D |
| Themes GUI | Super+Shift+T |

COSMIC: use COSMIC screenshot tooling or `grim` if installed.

---

## Wiring when files exist

1. Add PNGs under `docs/images/`.  
2. Embed in README / docs with **alt text** from tables.  
3. Flip Status → `CAPTURED` → `IN_README`.  

## Wave progress

| Item | Done |
|------|------|
| Purpose + alt text + capture notes for each shot | **yes** |
| Binary assets | **no** (not blocking handbook) |
