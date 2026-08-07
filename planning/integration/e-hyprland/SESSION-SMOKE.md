# Hyprland session smoke — post-merge gate (E-W1-004 freeze)

**Audience:** QA (Model G) and integrators after merging `lane/e-hyprland`.  
**Environment:** **new** user (skel applies only at account creation), Hyprland variant, SDDM → Hyprland.  
**Companion:** `KEYBIND-MAP.md` (86 active binds), `AUTOSTART.md`, `THEME-SYMLINKS.md`, `HANDOFF.md`.

Mark each line **PASS / FAIL / SKIP** (SKIP only where hardware-dependent and noted).

---

## Gate A — Pre-flight (must all PASS)

1. [ ] Image is **Hyprland** variant (not COSMIC-only session).
2. [ ] Test user created **after** the image/skel under test was installed.
3. [ ] Login reaches Hyprland (compositor up; not a bare VT).

## Gate B — First 60 seconds (visual)

4. [ ] **Wallpaper** — non-black background (hyprpaper; not swaybg).
5. [ ] **Waybar** — top bar with workspaces + clock.
6. [ ] **No crash dialogs** — no hyprland-dialog / portal spam on idle.
7. [ ] **Cursor** — pointer visible on all connected outputs.

## Gate C — Core apps & launcher

8. [ ] **Super+Return** — Ghostty opens.
9. [ ] **Super+T** — Ghostty opens (second terminal chord).
10. [ ] **Super+D** (or Super+Space) — Walker opens; typing filters desktop apps.
11. [ ] **Super+R** — Walker runner prefix (`>`) ready.
12. [ ] **Super+E** — Ghostty + yazi; quit cleanly.
13. [ ] **Super+B** — Neonwolf (or clear missing-binary failure — not wrong browser).
14. [ ] **Super+A** — FlatArcade TUI in Ghostty (**not** Assistant).
15. [ ] **xdg-open https://example.com** from terminal uses Neonwolf.

## Gate D — Screenshots, lock, theme

16. [ ] **Super+S** — region → clipboard (`wl-paste` / paste into Ghostty).
17. [ ] **Super+SHIFT+S** — region save under `~/Pictures` (dir exists).
18. [ ] **Super+SHIFT+L** — lock via `loginctl lock-session`; unlock with password.
19. [ ] Second Super+SHIFT+L does **not** stack hyprlock (`pgrep -c hyprlock` ≤ 1).
20. [ ] **Super+SHIFT+T** — ThemeSwitcher **floats + centers**; theme apply retints UI.

## Gate E — Session services & hygiene

21. [ ] `pgrep -a hypridle` after login.
22. [ ] `pgrep -a hyprpaper`; wallpaper path in `~/.config/hypr/hyprpaper.conf` exists.
23. [ ] `pgrep elephant` and Walker service respond to Super+D.
24. [ ] `notify-send 'hyprwave' 'mako ok'` shows a mako bubble.
25. [ ] **No** wofi / rofi / swaybg processes or binds (launcher=Walker, wallpaper=hyprpaper).
26. [ ] Theme indirection: `readlink -f ~/.config/hyprwave/theme` → `/usr/share/hyprwave/themes/<name>`.
27. [ ] `readlink -f ~/.config/waybar/style.css` resolves under that pack (not dangling).

## Gate F — Window rules spot-checks

28. [ ] Walker open has **no** slide-in fight (layerrule `no_anim` namespace walker).
29. [ ] Waybar **pulse** click → pavucontrol floats (and is usable).
30. [ ] Waybar **network** click → nm-connection-editor floats.

## Gate G — Optional / long / multi-monitor (SKIP if N/A)

31. [ ] **Super+SHIFT+E** exits session; Super+M alone does **nothing**.
32. [ ] Volume keys / mute work (`wpctl`); brightness keys best-effort on VM.
33. [ ] Multi-monitor: Super+period / Super+comma cycle focus; wallpaper on **all** outputs (`wallpaper = ,`).
34. [ ] hyprpaper restart: `pkill -x hyprpaper; hyprctl dispatch exec hyprpaper` restores art.
35. [ ] Idle (~10 min): session **locks** before DPMS blank (see hypridle ladder).
36. [ ] **Assistant inactive:** Super+SHIFT+A does not launch Assistant; skel bind stays commented.

---

**Minimum for post-merge PASS:** items **1–30** all PASS (31–36 SKIP only with reason).

## Idle ladder (reference)

| Seconds | Action |
|--------:|--------|
| 300 | dim (`brightnessctl` best-effort) |
| 600 | lock (`loginctl lock-session`) |
| 630 | DPMS off |
| 1200 | suspend |

## Failure triage

| Symptom | Likely cause | First fix |
|---------|--------------|-----------|
| No wallpaper | hyprpaper dead / bad path | `pgrep hyprpaper`; `hyprpaper.conf` |
| Empty Walker | elephant down | `pgrep elephant`; restart elephant + walker |
| Super+S noop | hyprshot/grim/slurp | `command -v hyprshot grim slurp` |
| Bar unstyled | theme symlink | THEME-SYMLINKS.md |
| Lock noop | hypridle/hyprlock | `loginctl lock-session` |
| Blank unlocked | old idle order | lock timeout &lt; DPMS |
| Theme GUI tiles | missing rule | class `dev.hyprwave.ThemeSwitcher` |
| Second monitor black | wallpaper binding | `wallpaper = , path`; restart hyprpaper |

## Sign-off

| Field | Value |
|-------|-------|
| Image / commit | |
| Tester | |
| Date (UTC) | |
| Gate A–F (1–30) | PASS / FAIL |
| Gate G notes | |
| Overall | PASS / FAIL |
