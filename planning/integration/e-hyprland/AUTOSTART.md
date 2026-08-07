# Hyprland first-session autostart order

**Task:** E-W1-001  
**Skel sources:** `build_files/etc/skel/.config/hypr/{hyprland,autostart}.conf`  
**Also:** `~/.config/autostart/walker.desktop`, systemd drop-in for walker restart

## Why order matters

Hyprland collects every `exec-once` from the final config (after `source` expansion) and
runs them **in file order** once the compositor is up. If portals start before
`WAYLAND_DISPLAY` is imported into the systemd user manager, screen share / file
dialogs can fail on the first login until something restarts them.

Walker 2.x has **no built-in providers** — it talks to **elephant**. Launching Walker
before elephant yields empty results or a silent miss on Super+D.

Hyprland does **not** always run XDG autostart. Relying only on
`~/.config/autostart/walker.desktop` is fragile on a raw `Exec=Hyprland` SDDM session.
We therefore **also** `exec-once` Walker; D-Bus activation is a singleton, so a second
start from the generator (when present) is harmless.

## Start sequence (first login)

| # | Source | Command / unit | Role |
|---|--------|----------------|------|
| 1 | `hyprland.conf` | `dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP` | Publish compositor env on session bus |
| 2 | `hyprland.conf` | `systemctl --user import-environment …` | Same vars into systemd --user |
| 3 | `hyprland.conf` | `/usr/libexec/polkit-kde-authentication-agent-1` | Auth agent for privileged actions |
| 4 | `autostart.conf` | `mkdir -p $HOME/Pictures` | Target dir for hyprshot file saves |
| 5 | `autostart.conf` | `hyprpaper` | Wallpaper (`hyprpaper.conf` → default or theme) |
| 6 | `autostart.conf` | `mako` | Notifications (config via theme symlink) |
| 7 | `autostart.conf` | `waybar` | Status bar |
| 8 | `autostart.conf` | `hypridle` | Idle → dim → lock → DPMS → suspend |
| 9 | `autostart.conf` | `/usr/libexec/xdg-desktop-portal-hyprland` | Wayland portal (needs #1–2) |
| 10 | `autostart.conf` | `elephant` | Walker provider backend |
| 11 | `autostart.conf` | `walker --gapplication-service` | Launcher daemon |
| — | XDG autostart (optional) | `walker.desktop` → same Walker service | Backup if generator runs |
| — | systemd drop-in | `app-walker@autostart.service.d/restart.conf` | `Restart=always` when unit is used |

## Wallpaper path (hyprpaper, not swaybg)

Skel `hyprpaper.conf`:

```
preload = /usr/share/hyprwave/wallpapers/default.png
wallpaper = , /usr/share/hyprwave/wallpapers/default.png
```

- Empty monitor field (`,`) applies the same image to **all** connected outputs
  (single or multi-monitor). Per-output lines use the name from `hyprctl monitors`
  (e.g. `wallpaper = eDP-1, /path`). See comments in skel `hyprpaper.conf`.
- `hyprwave-theme set <name>` regenerates `~/.config/hypr/hyprpaper.conf` with a
  theme wallpaper and restarts hyprpaper (see `/usr/bin/hyprwave-theme`). First boot
  does **not** require a theme switch to show a background.
- Hotplug blank screen: `pkill -x hyprpaper; hyprctl dispatch exec hyprpaper`.

## Explicit non-goals / removed patterns

| Avoid | Why |
|-------|-----|
| `swaybg` | Wallpaper is hyprpaper (source-built stack) |
| `wofi` / `rofi` / `dmenu` | Launcher is Walker |
| `nm-applet` | Network lives in Waybar → nm-connection-editor; tray icon ignores theme packs |
| Starting portal **before** dbus/import | First-login portal breakage |

## Restart cheatsheet (existing users)

```bash
# After skel-only overlay tests, new user accounts pick up configs automatically.
systemctl --user restart app-walker@autostart.service   # if unit exists
killall waybar mako hyprpaper elephant; hyprctl reload # soft UI bounce
# Walker service:
walker --gapplication-service &
elephant &
```

## Related files

- `KEYBIND-MAP.md` — every bind
- `SESSION-SMOKE.md` — 15 manual checks
- `HANDOFF.md` — package requests for other lanes (if any)
