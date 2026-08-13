# COSMIC variant (`hyprwave-cosmic`)

Hyprland is the default Hyprwave desktop. **hyprwave-cosmic** is a second bootc image
with System76’s **COSMIC** desktop and the same companions/theme identity.

---

## Quick facts

| | |
|--|--|
| Image | `ghcr.io/neon798/hyprwave-cosmic:latest` |
| Local build | `just build-cosmic` |
| ISO | `just build-iso-cosmic` |
| Greeter | **cosmic-greeter** (not SDDM) |
| Switch from Hyprland | `sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest` then reboot |

Full install paths: [INSTALL.md](../INSTALL.md).

---

## What you get

- Fedora `@cosmic-desktop-environment` + cosmic-greeter  
- Hyprwave **vendor defaults**: synthwave palette, default wallpaper, dock favorites  
  (Neonwolf, Cosmic Files, Ghostty, FlatArcade, Cosmic Settings)  
- Shared tools: Neonwolf, FlatArcade, Yazi, Ghostty, `hyprwave-theme`  
- **No** Hyprland, Walker, Waybar, Mako, or Hyprland skel configs  

### Declutter (intentional)

- **cosmic-store** removed — use **FlatArcade**  
- cosmic-edit / cosmic-player / cosmic-wallpapers removed as documented in the README  
  (use geany, mpv, Hyprwave wallpapers)  
- **cosmic-term** kept (session dependency); Ghostty is the promoted terminal  

---

## Themes

Same 11 packs and CLI/GUI as Hyprland:

```bash
hyprwave-theme list
hyprwave-theme set vaporwave
hyprwave-theme-gui
```

On COSMIC, the switcher writes appearance + wallpaper under `~/.config/cosmic/` (and
Ghostty). Some changes may need a moment or a session restart.

---

## Keybinds

Hyprland Super+… shortcuts in [keybinds.md](keybinds.md) **do not apply**. Use COSMIC’s
keyboard settings. Launch apps from the COSMIC launcher or dock. First-hour path:
[first-boot.md](first-boot.md).

---

## Greeter & session smoke

COSMIC image greeter and first-session expectations live under
`planning/integration/f-cosmic/` on `main`:

| Doc | Contents |
|-----|----------|
| [GREETER.md](../planning/integration/f-cosmic/GREETER.md) | `cosmic-greeter.service` as DM; session wallpaper vs greeter face; known limits (no SDDM-parity greeter theme) |
| [SESSION-SMOKE.md](../planning/integration/f-cosmic/SESSION-SMOKE.md) | Post-login checks (≥12): dock, wallpaper, Neonwolf, FlatArcade, Ghostty, theme switcher, no cosmic-store |
| [VENDOR-INVENTORY.md](../planning/integration/f-cosmic/VENDOR-INVENTORY.md) | Dock favorites order, CosmicBackground path, theme keys |
| [VENDOR-FIXES.md](../planning/integration/f-cosmic/VENDOR-FIXES.md) | Mode `is_dark`, dock reorder rationale |

**Operator takeaway:** greeter must yield a COSMIC session; Hyprwave branding is
**session**-oriented. Do not treat a stock greeter background as a failed install.

Dual-variant integration matrix:
[SMOKE-MATRIX.md](../planning/integration/g-qa/SMOKE-MATRIX.md).

---

## When to pick COSMIC vs Hyprland

| Prefer COSMIC if… | Prefer Hyprland if… |
|-------------------|---------------------|
| You want a full DE (panels, settings app, dock) | You want tiling WM + keyboard-driven flow |
| You like System76 COSMIC UX | You want Walker / Waybar / hypr ecosystem |
| You still want Neonwolf + FlatArcade + themes | You want Super+keybind defaults from skel |

You can switch images later with `bootc switch`; home data stays, desktop configs do not
auto-migrate. Decision tree: [INSTALL.md](../INSTALL.md#choose-a-variant-hyprland-vs-cosmic).

---

## Troubleshooting pointers

- Greeter issues → [troubleshooting.md](troubleshooting.md) (cosmic-greeter unit);
  [GREETER.md](../planning/integration/f-cosmic/GREETER.md) for enable/symlink expectations  
- Updates → [updating.md](updating.md)  
- Architecture → [architecture.md](architecture.md)  
- First boot → [first-boot.md](first-boot.md)  
