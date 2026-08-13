# HANDOFF — Model E (Hyprland skel)

**From:** Model E  
**Task:** E-W2-001  
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

## What changed for **new** users (E-W2-001)

| Area | Change |
|------|--------|
| **Super+SHIFT+A** | **Active** — `ghostty --class=dev.hyprwave.Assistant --title="Hyprwave Assistant" -e hyprwave-assistant` |
| **Super+SHIFT+T** | Unchanged — `hyprwave-theme-gui` (float+center+size) |
| **Super+SHIFT+E** | Unchanged — exit session |
| **Super+D / Space / R** | Unchanged — Walker / runner |
| **Super+A** | Still FlatArcade (not Assistant) |
| **windowrules** | Float/center/size for `dev.hyprwave.Assistant` and sized ThemeSwitcher |
| **autostart** | elephant + walker + waybar + mako + hyprpaper + hypridle (no cliphist) |
| **KEYBIND-MAP** | Resynced — **87** active binds, 0 commented binds |

## Explicit non-goals

- No **Wofi**, **swaybg**, **cliphist**, rofi, dmenu
- No COSMIC vendor / duress / `apps/` / `build.sh` edits
- No wholesale theme store rewrites

## Package residuals

**None** for E-W2-001. Host already has `localhost/hyprwave:latest` with
`hyprwave-assistant`, `ghostty`, `walker`, `elephant` on PATH (verified via
`podman run --rm localhost/hyprwave:latest command -v …`).

Walker emergency restart still targets:

```text
systemctl --user restart app-walker@autostart.service
```

(plus skel drop-in `Restart=always` under `app-walker@autostart.service.d/`).

## QA gate

Run `SESSION-SMOKE.md` (Wave 2) on a **new** user. Minimum: gates 1–32 PASS.

## Out of scope

COSMIC (F) · Duress (D) · Assistant app code (C) · `build.sh` (A)
