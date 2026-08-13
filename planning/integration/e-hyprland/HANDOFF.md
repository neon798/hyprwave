# HANDOFF — Model E (Hyprland skel)

**From:** Model E  
**Task:** E-W2-002 (builds on E-W2-001)  
**Date:** 2026-08-13  
**Branch:** `lane/e-hyprland`

## Existing-user caveat (critical)

Files under `build_files/etc/skel/` become `/etc/skel/` in the image and apply
**only when a user account is created**. Changing skel **does not** rewrite an
existing user’s `~/.config/hypr/**` (or walker/waybar/mako/… copies).

Integrator / operator options for existing accounts:

1. Create a **fresh test user** for smoke (preferred for QA).
2. Manually merge selected fragments from `/etc/skel/.config/…` into `~/.config`
   (user-owned; not an automated destructive migrator).
3. Theme switches still work via `hyprwave-theme` (indirection symlink), independent
   of bind/windowrule skel updates.

**E will not ship a home-directory migrator** that overwrites user config.

## What changed for **new** users (E-W2-002)

| Area | Change |
|------|--------|
| **hyprlock.conf / hypridle.conf** | Header comments document Super+SHIFT+L → `loginctl lock-session` → `pidof hyprlock \|\| hyprlock`; idle ladder unchanged |
| **waybar config.jsonc** | Tooltips name shipped tools (`nm-connection-editor`, `pavucontrol`, `blueman-manager`); header notes Walker / theme-gui / lock (no Wofi, no bar redesign) |
| **KEYBIND-MAP / SESSION-SMOKE** | Lock path one-liners aligned with comments |

## Prior (E-W2-001) still in skel

| Area | Change |
|------|--------|
| **Super+SHIFT+A** | **Active** — `ghostty --class=dev.hyprwave.Assistant --title="Hyprwave Assistant" -e hyprwave-assistant` |
| **Super+SHIFT+T** | `hyprwave-theme-gui` (float+center+size) |
| **Super+SHIFT+E** | exit session |
| **Super+D / Space / R** | Walker / runner |
| **Super+A** | FlatArcade (not Assistant) |
| **windowrules** | Float/center/size for Assistant + ThemeSwitcher |
| **autostart** | elephant + walker + waybar + mako + hyprpaper + hypridle (no cliphist) |
| **KEYBIND-MAP** | **87** active binds |

## Explicit non-goals

- No **Wofi**, **swaybg**, **cliphist**, rofi, dmenu
- No COSMIC vendor / duress / `apps/` / `build.sh` edits
- No wholesale theme store rewrites
- **No waybar visual redesign** (E-W2-002 is copy/tooltip only)

## Package residuals

**None.** Host has `localhost/hyprwave:latest`. Walker emergency restart still:

```text
systemctl --user restart app-walker@autostart.service
```

(plus skel drop-in `Restart=always` under `app-walker@autostart.service.d/`).

## QA gate

Run `SESSION-SMOKE.md` (Wave 2) on a **new** user. Minimum: gates 1–35 PASS.
Confirm Super+SHIFT+L does not stack hyprlock; waybar click tooltips match tools.

## Out of scope

COSMIC (F) · Duress (D) · Assistant app code (C) · `build.sh` (A)
