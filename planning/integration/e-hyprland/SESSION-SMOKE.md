# Hyprland session smoke checklist

**Audience:** QA (Model G) and anyone booting a fresh user after a skel change.  
**Environment:** new user account (skel only applies on account creation), Hyprland variant, graphical login via SDDM.

Copy this list into a PR or test log; mark each line PASS/FAIL.

## Pre-flight

- [ ] Image is Hyprland variant (not COSMIC-only session).
- [ ] Test user was created **after** the image/skel under test was installed.
- [ ] Login reaches Hyprland (not a black VT with no compositor).

## First 60 seconds (visual)

1. [ ] **Wallpaper** — non-black background appears (default.png or theme art).  
2. [ ] **Waybar** — top bar visible with workspaces + clock (right modules may vary on VM).  
3. [ ] **No crash dialogs** — hyprland-dialog / portal errors do not spam on idle.  
4. [ ] **Cursor** — pointer visible and moves on all connected outputs.

## Launcher & terminal

5. [ ] **Super+Return** — Ghostty window opens.  
6. [ ] **Super+D** (or Super+Space) — Walker opens quickly; typing filters desktop apps.  
7. [ ] **Super+R** — Walker runner prefix (`>`) ready for commands.  
8. [ ] **Super+E** — Ghostty launches `yazi`; quit yazi returns to shell or closes cleanly.

## Default apps story

9. [ ] **Super+B** — Neonwolf starts (or clearly fails with missing binary — not a wrong browser).  
10. [ ] **Super+A** — FlatArcade TUI in Ghostty.  
11. [ ] **From terminal:** `xdg-open https://example.com` uses Neonwolf (`BROWSER` / mimeapps).

## Screenshots, lock, theme

12. [ ] **Super+S** — region select; selection lands on clipboard (`wl-paste` or paste into Ghostty).  
13. [ ] **Super+SHIFT+S** — region save under `~/Pictures` (directory exists).  
14. [ ] **Super+SHIFT+L** — hyprlock screen; unlock with user password.  
15. [ ] **Super+SHIFT+T** — theme GUI floats/centered; applying a theme retints bar/borders without logout (or documents known reload).

## Extra checks (optional but useful)

- [ ] **Super+SHIFT+E** exits session (confirm you can log back in). Super+M alone must **not** exit.  
- [ ] **Volume keys** change sink volume (wpctl); mute toggles.  
- [ ] **Waybar network click** opens nm-connection-editor (floats).  
- [ ] **Waybar pulse click** opens pavucontrol (floats).  
- [ ] **Notifications:** `notify-send 'hyprwave' 'mako ok'` shows a mako bubble.  
- [ ] **Walker layer:** no open animation glitch (windowrules layerrule).  
- [ ] **Multi-monitor (if any):** Super+period / Super+comma cycle focus.  
- [ ] **Idle path (long):** leave idle per hypridle timeouts — dim → DPMS → lock (do not require full suspend in CI VMs).

## Failure triage (short)

| Symptom | Likely cause | First fix |
|---------|--------------|-----------|
| No wallpaper | hyprpaper dead / bad path | `pgrep hyprpaper`; check `~/.config/hypr/hyprpaper.conf` |
| Empty Walker | elephant not running | `pgrep elephant`; restart both |
| Walker never opens | service missing | `walker --gapplication-service &` |
| Portal file picker fails | env not imported | re-login; verify autostart order in AUTOSTART.md |
| Super+S does nothing | hyprshot/grim/slurp | `command -v hyprshot grim slurp` |
| Bar unstyled | broken theme symlink | `readlink -f ~/.config/waybar/style.css` |

## Sign-off

| Field | Value |
|-------|-------|
| Image / commit | |
| Tester | |
| Date (UTC) | |
| Result | PASS / FAIL |
| Notes | |
