# Screenshot checklist (handbook media)

**Status:** no binary screenshots in-repo — **all captures remain TODO**.  
Do **not** block INSTALL or the handbook on images.

| Field | Convention |
|-------|------------|
| Resolution | **2560×1440** or **1920×1080** preferred |
| Theme | Default pack **hyprwave** unless the shot demos another pack |
| Asset dir (reserved) | `docs/assets/` or `docs/images/` — see [docs/screenshots.md](../../../docs/screenshots.md) |
| Progress | `TODO` \| `CAPTURED` \| `IN_README` |

### Host blockers (read before capture)

| Blocker | Effect | Mitigation |
|---------|--------|------------|
| No graphical session / no compositor | `grim`, `hyprshot`, hypr binds unavailable | Boot Hyprland or COSMIC image in VM (`just run-vm-qcow2` / cosmic); do not capture from bare SSH TTY |
| Not on Hyprland | Super+S / hyprshot binds missing | Use COSMIC screenshot UI or install `grim`+`slurp` for region shots |
| Nested remote desktop only | Quality / keybind oddities | Prefer local KVM VM with virtio-gpu |
| Real passwords / PII on screen | Privacy fail | Use throwaway user; empty password field; no accounts in browser |
| Private GHCR (403) | Cannot pull published image for shots | Build local image + qcow2 (Path C in INSTALL) |
| Wrong local image tag | Overlay/docs expect `hyprwave:latest` | Justfile default `IMAGE_NAME=image-template` — use `just build hyprwave latest` / `IMAGE_NAME=hyprwave` (see INSTALL Path C) |
| Hyprland vs COSMIC mix-up | Wrong greeter/bar in shot | Hyprland: SDDM + Waybar/Walker. COSMIC: `just build-cosmic` / `run-vm-qcow2-cosmic`; cosmic-greeter + dock |

---

## Shared capture commands

### Hyprland (skel binds — prefer these on hypr image)

Source: `bindings.conf` / [docs/keybinds.md](../../../docs/keybinds.md)

| Goal | Keybind | Equivalent CLI (if hyprshot installed) |
|------|---------|----------------------------------------|
| Region → `~/Pictures` | **Super+Shift+S** | `hyprshot -m region -o ~/Pictures` |
| Region → clipboard | **Super+S** | `hyprshot -m region --clipboard-only` |
| Full output → file | **Super+Ctrl+Shift+S** | `hyprshot -m output -o ~/Pictures` |
| Full output → clipboard | **Super+Ctrl+S** | `hyprshot -m output --clipboard-only` |

Ensure target dir exists (autostart creates it):

```bash
mkdir -p ~/Pictures docs/assets
```

### Generic Wayland (works on both DEs if tools exist)

```bash
# Full outputs (grim)
grim ~/Pictures/shot-$(date +%Y%m%d-%H%M%S).png

# Region (grim + slurp)
grim -g "$(slurp)" ~/Pictures/region-$(date +%Y%m%d-%H%M%S).png
```

### COSMIC

- Prefer **COSMIC screenshot** UI (portal / Settings shortcut — version-dependent).
- Fallback: `grim` / `grim -g "$(slurp)"` from Ghostty if packages are present.
- No Super+S hyprshot binds.

### After capture

```bash
# Copy into reserved handbook tree (example)
cp ~/Pictures/YOUR.png docs/assets/hyprland-desktop.png
# Embed only with alt text from tables below; flip Status → CAPTURED
```

---

## Hyprland image

| # | Status | Shot | Purpose | Suggested file | Alt text | Exact capture command / sequence |
|---|--------|------|---------|----------------|----------|----------------------------------|
| H1 | TODO | SDDM greeter | Prove first-boot brand | `docs/assets/hyprland-sddm.png` | Hyprwave SDDM login: deep purple panel, chromatic HYPRWAVE title, user/password fields; no real password | Boot Hyprland image to greeter (do **not** log in). From another TTY/SSH **only if** a compositor capture path exists; else use VM host viewer screenshot. **Blocker:** pure SSH without display. Prefer hypervisor screenshot of greeter FB. |
| H2 | TODO | Empty desktop | Default skel look | `docs/assets/hyprland-desktop.png` | Hyprland desktop with synthwave wallpaper and Waybar; no open windows | Log in as **new** user; wait for waybar/hyprpaper. Then: `hyprshot -m output -o ~/Pictures` **or** Super+Ctrl+Shift+S. Copy to suggested file. |
| H3 | TODO | Walker open | Launcher is Walker | `docs/assets/hyprland-walker.png` | Walker launcher centered listing apps in synthwave CSS | Super+D (or `walker`). Region: Super+Shift+S / `hyprshot -m region -o ~/Pictures`. |
| H4 | TODO | Ghostty | Default terminal | `docs/assets/hyprland-ghostty.png` | Ghostty terminal with shell prompt on Hyprwave | Super+Return; optional `clear`. Super+Shift+S or `hyprshot -m region -o ~/Pictures`. |
| H5 | TODO | Neonwolf | Default browser | `docs/assets/hyprland-neonwolf.png` | Neonwolf browser with neutral page; no personal accounts | Super+B; open `about:blank` or local page. Super+Shift+S. |
| H6 | TODO | Yazi | Default file manager | `docs/assets/hyprland-yazi.png` | Yazi TUI inside Ghostty | Super+E. Super+Shift+S. |
| H7 | TODO | FlatArcade | App install path | `docs/assets/hyprland-flatarcade.png` | FlatArcade Flathub TUI arcade chrome | Super+A. Super+Shift+S. |
| H8 | TODO | Themes GUI | Theme product | `docs/assets/hyprland-themes-gui.png` | Hyprwave Themes GUI listing packs | Super+Shift+T (`hyprwave-theme-gui` from skel). Super+Shift+S region. |
| H9 | TODO | Theme variety | Multi-pack proof | `docs/assets/hyprland-theme-<name>.png` | Desktop under vaporwave / fjord-dark / verdant-haven | `hyprwave-theme set vaporwave` then H2 capture; repeat for other names. |
| H10 | TODO | Waybar crop | Bar modules | `docs/assets/hyprland-waybar.png` | Close-up Waybar: workspaces, network, clock | Super+Shift+S region over bar **or** `grim -g "$(slurp)" ~/Pictures/waybar.png`. |
| H11 | TODO | Mako | Notifications | `docs/assets/hyprland-mako.png` | Mako notification bubble themed | `notify-send 'Hyprwave' 'Test notification'` then Super+Shift+S quickly. |

## COSMIC image

| # | Status | Shot | Purpose | Suggested file | Alt text | Exact capture command / sequence |
|---|--------|------|---------|----------------|----------|----------------------------------|
| C1 | TODO | cosmic-greeter | Greeter differs from SDDM | `docs/assets/cosmic-greeter.png` | cosmic-greeter login on hyprwave-cosmic | Boot **hyprwave-cosmic** to greeter. Prefer VM host screenshot. **Blocker:** no compositor on capture host. |
| C2 | TODO | COSMIC desktop | Dock + wallpaper | `docs/assets/cosmic-desktop.png` | COSMIC desktop Hyprwave wallpaper and dock favorites (Neonwolf, FlatArcade, Ghostty, Cosmic Files, Hyprwave Themes, Cosmic Settings) | Fresh session after login on **hyprwave-cosmic**. `grim ~/Pictures/cosmic-desktop.png` **or** COSMIC screenshot UI. Confirm dock matches vendor favorites. |
| C3 | TODO | Companions | Shared apps | `docs/assets/cosmic-companions.png` | Ghostty and FlatArcade on COSMIC | Open from dock. `grim -g "$(slurp)" …` or DE screenshot. |
| C4 | TODO | Theme switcher | Themes on COSMIC | `docs/assets/cosmic-themes.png` | Theme UI or post-apply desktop | `hyprwave-theme-gui` or dock **Hyprwave Themes**. Capture with grim/slurp or DE tool. |
| C5 | TODO | Settings | Accent identity | `docs/assets/cosmic-settings.png` | Cosmic Settings with Hyprwave colors | Open Cosmic Settings. grim/slurp or DE tool. |

## Optional motion

| # | Status | Asset | Purpose | Alt / caption | Exact capture notes |
|---|--------|-------|---------|---------------|---------------------|
| M1 | TODO | GIF/WebM | Walker → terminal → theme | Recording of Super+D, Super+Return, Super+Shift+T | Hyprland only; `wf-recorder -f ~/Pictures/tour.webm` (if installed) or VM host record; keep ≤15s |
| M2 | TODO | Install flow | bootc path | Terminal `bootc switch` success then greeter | Capture terminal with grim; **no tokens/passwords**; greeter via VM screenshot |

---

## Wiring when files exist

1. Place PNGs under **`docs/assets/`** (preferred) or `docs/images/`.  
2. Embed in README / docs with **alt text** from tables.  
3. Flip Status → `CAPTURED` → `IN_README`.  
4. Do **not** commit multi‑MB marketing dumps in CI noise commits — keep handbook green without binaries.

## Wave progress

| Item | Done |
|------|------|
| Purpose + alt text for each shot | **yes** |
| Exact capture command / sequence per item | **yes** |
| Host/compositor blockers documented | **yes** (incl. IMAGE_NAME + DE mix-up; B-W2-002) |
| Binary assets | **no** / B-7 open (not blocking handbook) |
| Status column | All rows remain **TODO** — no captures invented |
