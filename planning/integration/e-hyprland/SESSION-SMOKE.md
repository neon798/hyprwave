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
14. [ ] **Super+SHIFT+L** — hyprlock screen via `loginctl lock-session`; unlock with user password.  
15. [ ] **Super+SHIFT+T** — theme GUI floats/centered; applying a theme retints bar/borders without logout (or documents known reload).

## Lock / idle / DPMS (E-W1-002)

Timeouts live in `~/.config/hypr/hypridle.conf` (dim 300s → lock 600s → DPMS 630s → suspend 1200s).

16. [ ] **hypridle running** — `pgrep -a hypridle` after login.  
17. [ ] **Lock keybind path** — Super+SHIFT+L shows lock; second press does **not** spawn a second hyprlock (`pgrep -c hyprlock` ≤ 1).  
18. [ ] **Manual lock CLI** — `loginctl lock-session` same UI as keybind.  
19. [ ] **hyprlock wallpaper** — brand image or solid fallback color (not a missing-file crash).  
20. [ ] **Idle dim (optional long)** — after ~5 min no input, backlight drops if `brightnessctl` works; on VMs without backlight, no error spam.  
21. [ ] **Idle lock (long)** — after ~10 min no input, session locks without needing the keybind.  
22. [ ] **DPMS after lock (long)** — ~30s after lock timeout, outputs blank; move mouse / type restores DPMS and shows lock (not an unlocked desktop).  
23. [ ] **Suspend lock (optional)** — `systemctl suspend` then resume still requires unlock (`before_sleep_cmd`). Skip if VM suspend is broken.

## Theme symlink integrity

24. [ ] **Indirection** — `readlink -f ~/.config/hyprwave/theme` → `/usr/share/hyprwave/themes/<name>`.  
25. [ ] **Relative chain** — `readlink -f ~/.config/waybar/style.css` and `looknfeel.conf` resolve under that pack (not dangling).  
26. [ ] **Theme switch** — `hyprwave-theme set <other>` updates indirection; waybar/mako colors change; hyprpaper wallpaper updates.  
27. [ ] **No stale launchers** — no wofi/rofi/swaybg processes or binds; wallpaper is hyprpaper; launcher is Walker.

## Window rules & hyprpaper (E-W1-003)

28. [ ] **Walker no-anim** — Super+D opens without a slide/fade fight over tiles (`layerrule` namespace walker).  
29. [ ] **ThemeSwitcher float** — Super+SHIFT+T window floats and centers (class `dev.hyprwave.ThemeSwitcher`).  
30. [ ] **pavucontrol float** — Waybar pulse click opens floating centered volume UI.  
31. [ ] **hyprpaper alive** — `pgrep -a hyprpaper`; wallpaper path in `~/.config/hypr/hyprpaper.conf` exists on disk.  
32. [ ] **Multi-monitor wallpaper (if ≥2 outputs)** — both show art; empty `wallpaper = ,` covers all (or per-output lines if user customized).  
33. [ ] **hyprpaper restart** — `pkill -x hyprpaper; hyprctl dispatch exec hyprpaper` restores wallpaper without logout.  
34. [ ] **Assistant bind inactive** — Super+SHIFT+A does **nothing** (or no Assistant) until C enables; Super+A still FlatArcade. Confirm commented line exists in `bindings.conf`.

## Extra checks (optional but useful)

- [ ] **Super+SHIFT+E** exits session (confirm you can log back in). Super+M alone must **not** exit.  
- [ ] **Volume keys** change sink volume (wpctl); mute toggles.  
- [ ] **Waybar network click** opens nm-connection-editor (floats).  
- [ ] **Waybar pulse click** opens pavucontrol (floats).  
- [ ] **Notifications:** `notify-send 'hyprwave' 'mako ok'` shows a mako bubble.  
- [ ] **Walker layer:** no open animation glitch (windowrules layerrule).  
- [ ] **Multi-monitor (if any):** Super+period / Super+comma cycle focus.  
- [ ] **Monitors default:** fresh skel has `monitor = , preferred, auto, 1` (not a foreign machine’s hardcode).  
- [ ] **HiDPI comment only:** scaling examples stay commented until the user opts in.

## Failure triage (short)

| Symptom | Likely cause | First fix |
|---------|--------------|-----------|
| No wallpaper | hyprpaper dead / bad path | `pgrep hyprpaper`; check `~/.config/hypr/hyprpaper.conf` |
| Empty Walker | elephant not running | `pgrep elephant`; restart both |
| Walker never opens | service missing | `walker --gapplication-service &` |
| Portal file picker fails | env not imported | re-login; verify autostart order in AUTOSTART.md |
| Super+S does nothing | hyprshot/grim/slurp | `command -v hyprshot grim slurp` |
| Bar unstyled | broken theme symlink | `readlink -f ~/.config/waybar/style.css` — see THEME-SYMLINKS.md |
| Lock does nothing | hypridle/hyprlock missing | `pgrep hypridle`; `command -v hyprlock`; try `loginctl lock-session` |
| Blank screen, unlocked | DPMS before lock (old conf) | ensure lock listener timeout &lt; DPMS timeout |
| Double lock UI | keybind execs hyprlock twice | keybind must be `loginctl lock-session` |
| Second monitor black | hyprpaper only bound one output | use `wallpaper = , path` or per-name lines; restart hyprpaper |
| Theme GUI tiles | missing float rule | class `dev.hyprwave.ThemeSwitcher` in windowrules.conf |

## Sign-off

| Field | Value |
|-------|-------|
| Image / commit | |
| Tester | |
| Date (UTC) | |
| Result | PASS / FAIL |
| Notes | |
