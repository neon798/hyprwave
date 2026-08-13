# Hyprland keybinds (Hyprwave defaults)

These bindings match the Hyprland skel file
`build_files/etc/skel/.config/hypr/bindings.conf` on `main`
(machine-readable map: `planning/integration/e-hyprland/KEYBIND-MAP.md`). New users
get a copy under `~/.config/hypr/bindings.conf` from `/etc/skel`.

`Super` is the Windows / Command key (`$mainMod = SUPER`). Layout assumption:
**dwindle** (see theme `looknfeel.conf`).

### Existing installs

Image upgrades do **not** rewrite `~/.config/hypr/`. Older homes may still use
**Super+M** to exit and master-layout ratio binds. New users (and a fresh copy
from `/etc/skel`) get **Super+Shift+E** exit and dwindle-safe focus/split
(documented below). Prefer live `~/.config/hypr/bindings.conf` on your machine
if it differs.

### COSMIC

These Super+… shortcuts **do not apply** on `hyprwave-cosmic`. Use COSMIC’s keyboard
settings and launcher. Themes still use **Hyprwave Themes** (`hyprwave-theme` /
`hyprwave-theme-gui`). See [cosmic.md](cosmic.md) and first-boot notes in
[first-boot.md](first-boot.md).

---

## Essentials

| Shortcut | Action |
|----------|--------|
| **Super + D** | Open **Walker** (app launcher) |
| **Super + Space** | Open **Walker** |
| **Super + R** | Walker **runner** mode (`walker --prefix ">"`) |
| **XF86Search** | Open Walker (hardware search key) |
| **Super + Return** | **Ghostty** terminal |
| **Super + T** | **Ghostty** terminal (alt muscle memory) |
| **Super + E** | **Yazi** file manager (in Ghostty) |
| **Super + B** | **Neonwolf** browser |
| **Super + A** | **FlatArcade** (Flathub TUI, in Ghostty) |
| **Super + Shift + T** | **Hyprwave Themes** GUI |
| **Super + Shift + A** | **Hyprwave Assistant** (`ghostty -e hyprwave-assistant`) |
| **Super + Q** | Close active window |
| **Super + F** | Fullscreen |
| **Super + W** | Toggle floating |
| **Super + Shift + E** | Exit Hyprland session (Shift required — avoids fat-finger Super+M) |
| **Super + Shift + L** | Lock (**hyprlock**) |
| **Super + Shift + P** | Color picker (**hyprpicker -a**, copy) |

---

## Walker prefixes (inside the launcher)

Configured in `~/.config/walker/config.toml` (not Hyprland binds):

| Prefix | Provider |
|--------|----------|
| `/` | Provider list |
| `.` | Files |
| `:` | Symbols |
| `=` | Calculator |
| `@` | Web search |
| `$` | Clipboard |
| `>` | Runner (also Super+R) |

---

## Windows, focus, move

| Shortcut | Action |
|----------|--------|
| Super + ←/→/↑/↓ | Move focus |
| Super + H / J / K / L | Move focus (vim) |
| Super + Shift + ←/→/↑/↓ | Move window |
| Super + Shift + H / J / K / L | Move window (vim) |
| Super + Alt + ←/→/↑/↓ | Resize active (±40 px) |
| Super + Alt + H / J / K / L | Resize active (vim) |
| Super + V | Toggle tab group |
| Super + Tab / Super + Shift + Tab | Next / previous in group |
| Super + P | Pseudo-tile (dwindle) |
| Super + mouse drag (LMB) | Move window (`bindm`) |
| Super + mouse drag (RMB) | Resize window (`bindm`) |

---

## Dwindle split / resize

| Shortcut | Action |
|----------|--------|
| Super + = | `layoutmsg togglesplit` |
| Super + − | `splitratio -0.05` (shrink) |
| Super + Shift + = | `splitratio +0.05` (grow; “+” key) |

Do **not** use master-only `setleftwideratio` — the default layout is dwindle (E-W1-001).

---

## Workspaces & monitors

| Shortcut | Action |
|----------|--------|
| Super + 1 … 0 | Switch to workspace 1–10 |
| Super + Shift + 1 … 0 | Move window to workspace 1–10 |
| Super + mouse wheel down/up | Next / previous workspace |
| Super + . / , | Focus next / previous monitor |

---

## Screenshots (hyprshot → grim/slurp)

`~/Pictures` is created on session start (`autostart.conf`).

| Shortcut | Action |
|----------|--------|
| Super + S | Region → clipboard |
| Super + Shift + S | Region → `~/Pictures` |
| Super + Ctrl + S | Full output → clipboard |
| Super + Ctrl + Shift + S | Full output → `~/Pictures` |

---

## Media & hardware keys

| Shortcut | Action |
|----------|--------|
| Volume up / down / mute | `wpctl` on default sink (raise capped at 150%) |
| Mic mute | Toggle default source mute |
| Brightness up / down | `brightnessctl` |
| Play / next / prev | `playerctl` (`binde` — holds repeat) |

---

## Themes (CLI)

Same themes as the GUI; works on Hyprland and COSMIC:

```bash
hyprwave-theme list
hyprwave-theme current
hyprwave-theme set vaporwave
hyprwave-theme menu
```

Store: `/usr/share/hyprwave/themes/` (11 packs). Full guide: [theming.md](theming.md).

---

## Intentional E-W1-001 changes (for upgraders)

| Change | Older skel | On main (new users) |
|--------|------------|---------------------|
| Session exit | Super+M | **Super+Shift+E** |
| Focus H/L | master `setleftwideratio` | **movefocus** (vim) |
| Split ratio | master ratio on minus | **splitratio** (dwindle) |
| Vim move/resize | missing | Super+Shift / Super+Alt + hjkl |

Full table: [planning/integration/e-hyprland/KEYBIND-MAP.md](../planning/integration/e-hyprland/KEYBIND-MAP.md).

---

## Customizing

Edit `~/.config/hypr/bindings.conf` (and other fragments under `~/.config/hypr/`).
Reload with `hyprctl reload`. Image defaults only re-apply for **new** users via
`/etc/skel` — see [architecture.md](architecture.md) and [first-boot.md](first-boot.md).
