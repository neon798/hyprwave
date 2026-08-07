# COSMIC first-login session smoke checklist

**Variant:** `hyprwave-cosmic` (`DE=cosmic`)  
**Task:** F-W1-001  
**How to get a session:** `just build-cosmic` then `just build-qcow2-cosmic` / `just run-vm-qcow2-cosmic`, or ISO via `just build-iso-cosmic`.  
**User under test:** brand-new account (vendor `/usr/share/cosmic` + `/etc/skel` only — not an upgraded home).

Mark each item **PASS / FAIL / SKIP** with a one-line note. Failures that only affect greeter go to `GREETER.md` known limits, not this list, unless session never starts.

---

## Pre-flight (image / VM)

1. **Image tag** — Container is `localhost/hyprwave-cosmic:latest` (or `ghcr.io/<owner>/hyprwave-cosmic:latest`).  
   - *How:* `podman images | grep hyprwave-cosmic` or bootc status inside guest.

2. **Display manager** — `display-manager.service` → `cosmic-greeter.service`, unit enabled.  
   - *How:* `systemctl status display-manager.service cosmic-greeter.service`

3. **Declutter packages absent** — `cosmic-store`, `cosmic-edit`, `cosmic-player`, `cosmic-wallpapers` not installed.  
   - *How:* `rpm -q cosmic-store cosmic-edit cosmic-player cosmic-wallpapers` → all “not installed”.

4. **Session-critical packages present** — `cosmic-session`, `cosmic-comp`, `cosmic-panel`, `cosmic-settings`, `cosmic-term`, `cosmic-greeter`, `ghostty` installed.  
   - *How:* `rpm -q …`

5. **Vendor wallpaper staged** — `/usr/share/backgrounds/hyprwave/default.png` readable and matches Hyprwave default art.  
   - *How:* `file /usr/share/backgrounds/hyprwave/default.png` (PNG); visual check after login.

6. **Vendor config layer present** — `/usr/share/cosmic/com.system76.CosmicAppList/v1/favorites` and theme trees exist.  
   - *How:* `test -f` those paths; `wc -l` favorites shows six IDs.

---

## Greeter → session

7. **Login screen appears** — After boot, cosmic-greeter shows user list / password field without falling back to a text console.  
   - *Note:* Greeter wallpaper/branding limits → `GREETER.md`.

8. **Session starts** — Password accepted → COSMIC desktop (panel + dock + wallpaper), no black screen loop.  
   - *How:* `echo $XDG_CURRENT_DESKTOP` contains `COSMIC` (case may vary); `pgrep -a cosmic-session`.

---

## First-login desktop identity

9. **Wallpaper** — Desktop background is Hyprwave `default.png` (synthwave), not Fedora stock cosmic-wallpapers.  
   - *How:* Visual; or read `~/.config/cosmic/com.system76.CosmicBackground/v1/all` if user copied defaults, else vendor path above.

10. **Dark synthwave chrome** — Panel/dock/windows use dark purple base (`#15052e` family), pink accent, cyan window hints — not stock blue COSMIC.  
    - *How:* Visual; Settings → Desktop → Appearance shows dark theme active.

11. **Dock favorites (minimum five)** — Dock (or app list favorites) includes:
    - Neonwolf  
    - FlatArcade  
    - Ghostty  
    - COSMIC Files  
    - COSMIC Settings  
    - *Optional sixth:* Hyprwave Themes  
    - *How:* Visual dock; or `cat /usr/share/cosmic/com.system76.CosmicAppList/v1/favorites` if user has no override.

12. **Neonwolf launches** — Favorite opens the browser (extracted AppImage under `/usr/lib/neonwolf`).  
    - *How:* Click dock icon; window appears.

13. **Ghostty launches** — Terminal opens with Hyprwave-oriented colors from skel (`~/.config/ghostty` from `/etc/skel`).  
    - *How:* Click dock; `echo $TERM` works.

14. **FlatArcade launches** — Opens in Ghostty as Flathub TUI (not cosmic-store).  
    - *How:* Click dock; no “command not found”; no residual cosmic-store icon required.

15. **COSMIC Files + Settings** — Both open native COSMIC apps from dock.

16. **Theme switcher available** — `hyprwave-theme list` works; `hyprwave-theme set <name>` updates COSMIC colors + wallpaper into `~/.config/cosmic/` without logout (best-effort daemon restart).  
    - *How:* `hyprwave-theme list`; switch to e.g. `fjord-dark` then back to `hyprwave`.

17. **Skel theme indirection** — New user has `~/.config/hyprwave/theme` → `/usr/share/hyprwave/themes/hyprwave`.  
    - *How:* `readlink -f ~/.config/hyprwave/theme`

18. **Yazi available** — `yazi` runs inside Ghostty (shared install; skel yazi config if present).  
    - *How:* `ghostty -e yazi` or from shell.

19. **No Hyprland-only chrome** — No waybar/walker/mako required for a working session; COSMIC panel/launcher/notifications own the shell.  
    - *How:* `pgrep waybar` / `pgrep walker` should be empty on a pure COSMIC login.

20. **cosmic-term still present but not promoted** — `rpm -q cosmic-term` OK; not required on dock.  
    - *Why:* session hard-dep; Ghostty is the intentional default terminal UX.

---

## Negative / regression probes

21. **cosmic-store gone** — Launcher search for “COSMIC Store” / `cosmic-store` finds nothing usable.  
22. **User override wins** — After `hyprwave-theme set vaporwave`, favorites remain; wallpaper/theme change under `~/.config/cosmic/` and survive a logout/login.

---

## Sign-off

| Field | Value |
|---|---|
| Tester | |
| Image digest / tag | |
| Date (UTC) | |
| Result | ☐ all critical PASS · ☐ FAIL (list IDs) |

**Critical for ship:** items 2–5, 7–15, 21.  
**Nice-to-have:** 16–18, 22, greeter wallpaper polish.
