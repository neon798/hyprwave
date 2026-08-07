# HANDOFF — Model E → other lanes

**From:** Model E (Hyprland skel)  
**Task:** E-W1-003  
**Date:** 2026-08-07

## Package / build.sh requests

None required for E-W1-003. Already present on the Hyprland variant (read-only
check of `build_files/build.sh` — not edited):

- waybar, walker, elephant (+ plugins), mako, hypridle, hyprlock, hyprpaper  
- grim, slurp, wl-clipboard, hyprshot (source-built), brightnessctl, playerctl  
- ghostty, yazi, neonwolf, flatarcade  
- xdg-desktop-portal-hyprland, polkit-kde-agent, fontawesome-fonts, jetbrains-mono-fonts  

If a future smoke test finds **hyprshot** missing from a build that skipped
`build-hypr-utils`, that is lane A / builder territory — not skel.

## Assistant bind (Model C + integrator)

Skel **does not** enable a live Assistant keybind (binary may be absent; Super+A
is FlatArcade). A **commented** line is reserved in
`build_files/etc/skel/.config/hypr/bindings.conf`:

```bash
# bind = $mainMod SHIFT, A, exec, hyprwave-assistant
```

### Steps after C merges `hyprwave-assistant` onto the image

1. Confirm package/binary: `command -v hyprwave-assistant` on a built image.
2. In skel `bindings.conf`, **uncomment** the Super+SHIFT+A line (leave Super+A
   as FlatArcade unless product explicitly reassigns it).
3. Optionally add a float rule in `windowrules.conf` if the Assistant window
   should be modal (class/app-id TBD by C — E will accept a follow-up OPEN task).
4. Update `KEYBIND-MAP.md`: move the row from “Future / commented” → active table.
5. Add a SESSION-SMOKE item: Super+SHIFT+A launches Assistant.
6. Integrator/A: no `build.sh` change from E; C owns packaging HANDOFF to A if needed.

**Owner:** Model C (app) + integrator for uncomment; E only reserves the chord.

## Optional future work (do not block DONE)

| Need | Why | Owner |
|------|-----|-------|
| Theme-aware hyprlock wallpaper | Lock uses brand default; switcher does not rewrite hyprlock | Switcher owner if product wants it |
| `cliphist` or similar | Walker `$` clipboard richer with history daemon | A if desired |
| `uwsm` | systemd graphical-session for XDG autostart only | A — low priority |
| Theme pack missing component | Dangling skel symlink into a pack | Theme pack lane |

## Docs for G (QA)

- `AUTOSTART.md` — start order + multi-monitor hyprpaper notes  
- `KEYBIND-MAP.md` — binds + **commented future** Assistant chord  
- `SESSION-SMOKE.md` — lock/idle/theme + windowrule/hyprpaper checks  
- `THEME-SYMLINKS.md` — indirection layout  
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
- Assistant app implementation — C  
- Theme pack wholesale regeneration — deferred  
- `build.sh` package lists — A / HANDOFF only  
