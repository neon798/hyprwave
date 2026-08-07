# Hyprland keybinds (Hyprwave defaults)

These bindings come from the default user config
`~/.config/hypr/bindings.conf` (seeded from `/etc/skel` for **new** users).
`Super` is the Windows / Command key (`$mainMod = SUPER`).

COSMIC variant users: these shortcuts **do not apply**. Use COSMIC’s own
keybindings; themes still use **Hyprwave Themes** from the app menu or
`hyprwave-theme` in a terminal.

---

## Essentials

| Shortcut | Action |
|----------|--------|
| **Super + D** | Open **Walker** (app launcher) |
| **Super + Space** | Open **Walker** |
| **Super + R** | Walker **runner** mode (`walker --prefix ">"`) |
| **XF86Search** | Open Walker (hardware search key) |
| **Super + Return** | **Ghostty** terminal |
| **Super + T** | **Ghostty** terminal |
| **Super + E** | **Yazi** file manager (in Ghostty) |
| **Super + B** | **Neonwolf** browser |
| **Super + A** | **FlatArcade** (Flathub TUI, in Ghostty) |
| **Super + Shift + T** | **Hyprwave Themes** GUI |
| **Super + Q** | Close active window |
| **Super + F** | Fullscreen |
| **Super + W** | Toggle floating |
| **Super + M** | Exit Hyprland session |
| **Super + Shift + L** | Lock (**hyprlock**) |
| **Super + Shift + P** | Color picker (**hyprpicker**, copy) |

---

## Walker prefixes (inside the launcher)

Configured in `~/.config/walker/config.toml`:

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

## Windows & focus

| Shortcut | Action |
|----------|--------|
| Super + ←/→/↑/↓ | Move focus |
| Super + Shift + ←/→/↑/↓ | Move window |
| Super + Alt + ←/→/↑/↓ | Resize active window |
| Super + V | Toggle group |
| Super + Tab / Super + Shift + Tab | Next / previous in group |
| Super + H / L / − | Master layout ratio (left wider −/+) |
| Super + = | Toggle split (layoutmsg) |
| Super + P | Pseudo-tile |
| Super + mouse drag (LMB) | Move window |
| Super + mouse drag (RMB) | Resize window |

---

## Workspaces

| Shortcut | Action |
|----------|--------|
| Super + 1 … 0 | Switch to workspace 1–10 |
| Super + Shift + 1 … 0 | Move window to workspace 1–10 |
| Super + mouse wheel down/up | Next / previous workspace |
| Super + . / , | Focus next / previous monitor |

---

## Screenshots (hyprshot → grim/slurp)

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
| Volume up / down / mute | `wpctl` on default sink |
| Mic mute | Toggle default source mute |
| Brightness up / down | `brightnessctl` |
| Play / next / prev | `playerctl` |

---

## Themes (CLI)

Same themes as the GUI; works on Hyprland and COSMIC:

```bash
hyprwave-theme list
hyprwave-theme current
hyprwave-theme set vaporwave
hyprwave-theme menu
```

Store: `/usr/share/hyprwave/themes/` (11 packs).

---

## Customizing

Edit `~/.config/hypr/bindings.conf` (and other fragments under `~/.config/hypr/`).
Reload Hyprland after changes (`hyprctl reload` or your usual reload bind if you add
one). Image defaults only re-apply for **new** users via `/etc/skel`.
