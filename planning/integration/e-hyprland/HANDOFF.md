# HANDOFF — Model E → other lanes

**From:** Model E (Hyprland skel)  
**Task:** E-W1-001  
**Date:** 2026-08-07

## Package / build.sh requests

None required for E-W1-001. The following are **already** installed on the Hyprland
variant (verified by reading `build_files/build.sh` only — not edited):

- waybar, walker, elephant (+ plugins), mako, hypridle, hyprlock  
- grim, slurp, wl-clipboard, hyprshot (source-built), brightnessctl, playerctl  
- ghostty, yazi, neonwolf, flatarcade  
- xdg-desktop-portal-hyprland, polkit-kde-agent, fontawesome-fonts, jetbrains-mono-fonts  

If a future smoke test finds **hyprshot** missing from a build that skipped
`build-hypr-utils`, that is lane A / builder territory — not skel.

## Optional future package ideas (do not block DONE)

| Need | Why | Owner |
|------|-----|-------|
| `cliphist` or similar | Walker `$` clipboard provider is richer with a history daemon | A if desired |
| `uwsm` | Proper systemd graphical-session for XDG autostart only | A — low priority; we exec-once Walker |

## Docs for G (QA)

- `AUTOSTART.md` — start order  
- `KEYBIND-MAP.md` — full bind table  
- `SESSION-SMOKE.md` — 15+ manual checks  

## Out of scope (other lanes)

- COSMIC vendor tree — F  
- Duress — D  
- Assistant app — C  
- Theme pack wholesale regeneration — deferred  
