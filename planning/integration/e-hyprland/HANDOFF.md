# HANDOFF — Model E → other lanes

**From:** Model E (Hyprland skel)  
**Task:** E-W1-002  
**Date:** 2026-08-07

## Package / build.sh requests

None required for E-W1-002. Already present on the Hyprland variant (read-only
check of `build_files/build.sh` — not edited):

- waybar, walker, elephant (+ plugins), mako, hypridle, hyprlock  
- grim, slurp, wl-clipboard, hyprshot (source-built), brightnessctl, playerctl  
- ghostty, yazi, neonwolf, flatarcade  
- xdg-desktop-portal-hyprland, polkit-kde-agent, fontawesome-fonts, jetbrains-mono-fonts  

If a future smoke test finds **hyprshot** missing from a build that skipped
`build-hypr-utils`, that is lane A / builder territory — not skel.

## Optional future work (do not block DONE)

| Need | Why | Owner |
|------|-----|-------|
| Theme-aware hyprlock wallpaper | Lock uses brand `/usr/share/hyprwave/wallpapers/default.png`; switcher does not rewrite hyprlock | Theme switcher owner (not skel) if product wants it |
| `cliphist` or similar | Walker `$` clipboard provider is richer with a history daemon | A if desired |
| `uwsm` | Proper systemd graphical-session for XDG autostart only | A — low priority; we exec-once Walker |
| Theme pack missing component | If `readlink -f` on a skel symlink dangles for a named pack | Theme pack lane — E only fixes skel link shape |

## Docs for G (QA)

- `AUTOSTART.md` — start order  
- `KEYBIND-MAP.md` — full bind table (lock bind = loginctl)  
- `SESSION-SMOKE.md` — login + **lock/idle/theme symlink** checks  
- `THEME-SYMLINKS.md` — indirection layout and verify commands  
- `HANDOFF.md` — this file  

## Idle chain (for QA expectation)

| Seconds | Action |
|--------:|--------|
| 300 | dim (`brightnessctl`, best-effort) |
| 600 | `loginctl lock-session` → hyprlock |
| 630 | DPMS off |
| 1200 | `systemctl suspend` |

## Out of scope (other lanes)

- COSMIC vendor tree — F  
- Duress — D  
- Assistant app — C  
- Theme pack wholesale regeneration — deferred  
- `build.sh` package lists — A / HANDOFF only  
