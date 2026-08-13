# HANDOFF — Model E (Hyprland skel)

**From:** Model E  
**Task:** E-W4-001 (merge-prep; builds on E-W2 / E-W3)  
**Date:** 2026-08-13  
**Branch:** `lane/e-hyprland`  
**Product tip (integrator):** **`d8db11f`** — last `hyprland:` product commit (E-W3-001); KEYBIND-MAP stamps this SHA

## Existing-user caveat (critical)

Files under `build_files/etc/skel/` become `/etc/skel/` in the image and apply
**only when a user account is created**. Changing skel **does not** rewrite an
existing user’s `~/.config/hypr/**` (or walker/waybar/mako/… copies).

| Audience | Effect |
|----------|--------|
| **New user** | Full skel on first login; use for SESSION-SMOKE / INTEGRATION-DAY |
| **Existing home** | Unchanged by this lane; operator may hand-merge from `/etc/skel` |

Integrator / operator options for existing accounts:

1. Create a **fresh test user** for smoke (preferred for QA).
2. Manually merge selected fragments from `/etc/skel/.config/…` into `~/.config`
   (user-owned; not an automated destructive migrator).
3. Theme switches still work via `hyprwave-theme` (indirection symlink), independent
   of bind/windowrule skel updates.

**E will not ship a home-directory migrator** that overwrites user config.

## Exclusive files vs `origin/main` (E-W4-001 merge list)

Model E **only** touches these paths. Integrator merge should take this list from
`lane/e-hyprland` (do **not** expect E to PR-merge onto main).

### Skel product (behavior for new users)

| Path | Role |
|------|------|
| `build_files/etc/skel/.config/hypr/autostart.conf` | elephant/walker/waybar/mako/hyprpaper/hypridle order |
| `build_files/etc/skel/.config/hypr/bindings.conf` | Super+SHIFT+A assistant class; dwindle binds; 87 binds |
| `build_files/etc/skel/.config/hypr/windowrules.conf` | float Assistant + ThemeSwitcher |
| `build_files/etc/skel/.config/hypr/hyprlock.conf` | lock path comments |
| `build_files/etc/skel/.config/hypr/hypridle.conf` | lock_cmd + ladder comments |
| `build_files/etc/skel/.config/hypr/hyprland.conf` | dwindle/theme looknfeel comments |
| `build_files/etc/skel/.config/waybar/config.jsonc` | tooltips (nm/pavu/blueman) |

### Integration notes (operators / QA)

| Path | Role |
|------|------|
| `planning/integration/e-hyprland/KEYBIND-MAP.md` | 87 binds + product tip SHA **`d8db11f`** |
| `planning/integration/e-hyprland/SESSION-SMOKE.md` | Wave 2–4 gates + image inspect + new/existing caveat |
| `planning/integration/e-hyprland/INTEGRATION-DAY.md` | one-page smoke card + new/existing caveat |
| `planning/integration/e-hyprland/HANDOFF.md` | this file |
| `planning/integration/e-hyprland/README.md` | index (minor) |

Unchanged exclusive trees this wave (no delta vs prior E work, may already match main if partially merged): walker, mako, ghostty, yazi, autostart desktop, systemd user drop-in, AUTOSTART.md, THEME-SYMLINKS.md.

## What changed for **new** users (E-W4-001)

| Area | Change |
|------|--------|
| **INTEGRATION-DAY / SESSION-SMOKE** | Explicit new-user vs existing-home tables; product tip `d8db11f` |
| **KEYBIND-MAP** | Lane product tip SHA table (W3 inspect / W2 lock stack) |
| **HANDOFF** | Exclusive merge file list vs `origin/main` |

## Prior (E-W3-001) still in skel

| Area | Change |
|------|--------|
| **SESSION-SMOKE** | Container inspect addendum for `localhost/hyprwave:latest` (assistant, hyprpaper, walker, 11 themes, no wofi/swaybg) |
| **dwindle comments** | `hyprland.conf` + `bindings.conf` document theme `layout = dwindle` and togglesplit/splitratio; **no** gap/border/animation change (`looknfeel` remains theme symlink) |

## Prior (E-W2-002) still in skel

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
