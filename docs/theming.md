# Theming

Hyprwave ships **11 switchable theme packs** for both desktop variants. Packs live in
the system theme store; your session points at one pack via an indirection symlink.

---

## Theme store

```text
/usr/share/hyprwave/themes/<name>/
```

| Name | Character |
|------|-----------|
| **hyprwave** (default) | Classic synthwave |
| retro-arcade | 80s arcade cabinets |
| cozy-harvest | Warm earthy farm life |
| fjord-dark | Clean cold nordic |
| touge-drive | Night mountain racing |
| vaporwave | 80s/90s vapor |
| highway-haze | Misty neon drive |
| lunar-pulse | Dreamy moonlit |
| glitch-horizon | Glitchy retro future |
| arcade-rain | Rainy neon arcade |
| verdant-haven | Immersive nature |

Each pack can include whole-file components (Hyprland chrome, Ghostty, Waybar, Walker,
Mako, wallpapers, COSMIC config keys, optional SDDM assets). Exact files vary by pack.

---

## Switch themes (GUI)

1. Open **Hyprwave Themes** from the app launcher (desktop entry
   `hyprwave-theme.desktop` → `hyprwave-theme-gui`).
2. On **Hyprland**, press **Super+Shift+T** (from skel `bindings.conf`).
3. Pick a theme → **Apply theme**.

No terminal required for the common path.

---

## Switch themes (CLI)

```bash
hyprwave-theme list          # * marks current
hyprwave-theme current
hyprwave-theme set vaporwave
hyprwave-theme set verdant-haven forest   # optional scene when pack supports it
hyprwave-theme menu          # interactive picker
```

Indirection path used by the switcher:

```text
~/.config/hyprwave/theme  →  /usr/share/hyprwave/themes/<name>
```

---

## What gets updated

| Surface | Hyprland image | COSMIC image |
|---------|----------------|--------------|
| Wallpaper | hyprpaper reload | COSMIC wallpaper / bg keys |
| Borders / look | hypr live-reload | Appearance key trees under `~/.config/cosmic/` |
| Waybar / Walker / Mako | Reloaded / symlink | N/A (COSMIC chrome) |
| Ghostty | Colors on **new** windows | Same |
| SDDM greeter | Optional polkit helper refresh | N/A (cosmic-greeter) |

If something looks stale: open a new terminal, re-run `hyprwave-theme set …`, or
restart the session. Existing users without skel symlinks may need the switcher once
to create `~/.config/hyprwave/theme`.

---

## Default palette (hyprwave pack)

| Token | Hex | Use |
|-------|-----|-----|
| Background | `#15052e` | Deep purple |
| Foreground | `#e0e0ff` | Light text |
| Pink | `#ff2d95` | Accent |
| Cyan | `#00f0ff` | Highlight / window hint |
| Purple | `#b967ff` | Trim / neutral |

SDDM and Walker CSS for the default look follow the same family.

---

## Customizing without breaking upgrades

- Prefer **user** overrides under `~/.config/` rather than editing `/usr/share/hyprwave/`.
- Image upgrades replace `/usr` theme store content; your **selected** pack name still
  works if the pack still ships.
- `/etc/skel` only seeds **new** users — see [architecture.md](architecture.md).

---

## Related

- [keybinds.md](keybinds.md) — Super+Shift+T  
- [cosmic.md](cosmic.md) — COSMIC-specific apply behavior  
- [troubleshooting.md](troubleshooting.md) — theme switch did nothing  
- [README.md](../README.md#themes) — short product list  
