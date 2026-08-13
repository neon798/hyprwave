# Hyprland session smoke — Wave 2–4 gate (E-W2-001 + E-W3-001 inspect + E-W4-001 merge-prep)

**Audience:** QA (Model G) and integrators after merging `lane/e-hyprland`.  
**Environment:** **new** user (skel applies only at account creation), Hyprland variant, SDDM → Hyprland.  
**Companion:** `KEYBIND-MAP.md` (87 active binds; product tip **`d8db11f`**), `AUTOSTART.md`, `THEME-SYMLINKS.md`, `HANDOFF.md`, `INTEGRATION-DAY.md`.

## New user vs existing home (E-W4-001)

| | |
|--|--|
| **New user** | `/etc/skel` → `~/.config` at **account creation only**. All gates below assume this. |
| **Existing home** | Image updates **do not** overwrite `~/.config/hypr/**` (or walker/waybar/…). Super+SHIFT+A float class, lock comments, waybar tooltips from this lane **will not** land automatically. Prefer a **fresh test user** for smoke; manual merge is operator-owned. **No home migrator** ships from Model E. |

**Image note:** host builds may expose `localhost/hyprwave:latest` for container checks (`command -v hyprwave-assistant`, etc.). Full session smoke still needs a VM/boot. Container inspect (below) is **not** a substitute for Gates B–H.

Mark each line **PASS / FAIL / SKIP** (SKIP only where hardware-dependent and noted).

---

## Container inspect — `localhost/hyprwave:latest` (E-W3-001)

Host inspect only (no full Hyprland session). Re-run after rebuilds; do not invent PASS if the image is missing.

| Check | Result | Notes |
|-------|--------|-------|
| Image present | **PASS** | `localhost/hyprwave:latest` ID `9bc0e1e57d6b` (Created 2026-08-13T03:16:36Z) |
| Hyprland session file | **PASS** | `/usr/share/wayland-sessions/hyprland.desktop`; `hyprland` RPM 0.56.2 |
| `hyprwave-assistant` on PATH | **PASS** | `/usr/sbin/hyprwave-assistant` |
| Super+SHIFT+A in image skel | **PASS*** | Image skel: `ghostty -e hyprwave-assistant` (no `--class` yet). **Lane** skel uses `--class=dev.hyprwave.Assistant` for float rules — rebuild to pick up. |
| `hyprpaper` on PATH + skel | **PASS** | Binary present; skel preload/wallpaper → `/usr/share/hyprwave/wallpapers/default.png` (not swaybg) |
| `walker` + `elephant` on PATH | **PASS** | Both `/usr/sbin/…`; skel `exec-once` elephant then walker service |
| Theme packs count | **PASS** | **11** under `/usr/share/hyprwave/themes/` (arcade-rain, cozy-harvest, fjord-dark, glitch-horizon, highway-haze, hyprwave, lunar-pulse, retro-arcade, touge-drive, vaporwave, verdant-haven) |
| Default looknfeel layout | **PASS** | Theme `hyprwave`: `general.layout = dwindle` (gaps_in 5 / gaps_out 10 / border 2) — comments only in skel; no redesign |
| No wofi / swaybg / cliphist / rofi | **PASS** | `command -v` all absent in image |
| Full graphical smoke (Gates B–H) | **SKIP** | Needs VM/boot + new user; not run in this inspect |

**Inspect stamp:** 2026-08-13T03:35Z · Model E · branch `lane/e-hyprland`

---

## Gate A — Pre-flight (must all PASS)

1. [ ] Image is **Hyprland** variant (not COSMIC-only session).
2. [ ] Test user created **after** the image/skel under test was installed.
3. [ ] Login reaches Hyprland (compositor up; not a bare VT).
4. [ ] `command -v hyprwave-assistant ghostty walker elephant hyprpaper` all succeed (in session or image).

## Gate B — First 60 seconds (visual)

5. [ ] **Wallpaper** — non-black background (hyprpaper; not swaybg).
6. [ ] **Waybar** — top bar with workspaces + clock.
7. [ ] **No crash dialogs** — no hyprland-dialog / portal spam on idle.
8. [ ] **Cursor** — pointer visible on all connected outputs.

## Gate C — Core apps & launcher

9. [ ] **Super+Return** — Ghostty opens.
10. [ ] **Super+T** — Ghostty opens (second terminal chord).
11. [ ] **Super+D** (or Super+Space) — Walker opens; typing filters desktop apps.
12. [ ] **Super+R** — Walker runner prefix (`>`) ready.
13. [ ] **Super+E** — Ghostty + yazi; quit cleanly.
14. [ ] **Super+B** — Neonwolf (or clear missing-binary failure — not wrong browser).
15. [ ] **Super+A** — FlatArcade TUI in Ghostty (**not** Assistant).
16. [ ] **xdg-open https://example.com** from terminal uses Neonwolf.

## Gate D — Theme + Assistant (Wave 2)

17. [ ] **Super+SHIFT+T** — ThemeSwitcher **floats + centers** (class `dev.hyprwave.ThemeSwitcher`); apply retints UI.
18. [ ] **Super+SHIFT+A** — Assistant TUI launches in Ghostty; window **floats + centers** (class `dev.hyprwave.Assistant`); quit returns cleanly.
19. [ ] Assistant window is **not** a full-tile Ghostty clone of Super+Return (dedicated class / rule).
20. [ ] Super+A still opens FlatArcade (no chord collision with Super+SHIFT+A).

## Gate E — Screenshots & lock

21. [ ] **Super+S** — region → clipboard (`wl-paste` / paste into Ghostty).
22. [ ] **Super+SHIFT+S** — region save under `~/Pictures` (dir exists).
23. [ ] **Super+SHIFT+L** — lock via `loginctl lock-session`; unlock with password.
24. [ ] Second Super+SHIFT+L does **not** stack hyprlock (`pgrep -c hyprlock` ≤ 1).

## Gate F — Session services & hygiene

25. [ ] `pgrep -a hypridle` after login.
26. [ ] `pgrep -a hyprpaper`; wallpaper path in `~/.config/hypr/hyprpaper.conf` exists.
27. [ ] `pgrep elephant` and Walker service respond to Super+D.
28. [ ] `notify-send 'hyprwave' 'mako ok'` shows a mako bubble.
29. [ ] **No** wofi / rofi / swaybg / cliphist processes or binds.
30. [ ] Theme indirection: `readlink -f ~/.config/hyprwave/theme` → `/usr/share/hyprwave/themes/<name>`.
31. [ ] `readlink -f ~/.config/waybar/style.css` resolves under that pack (not dangling).
32. [ ] Walker emergency “Restart Walker” restarts `app-walker@autostart.service` (or service recovers via Restart=always).

## Gate G — Window rules spot-checks

33. [ ] Walker open has **no** slide-in fight (layerrule `no_anim` namespace walker).
34. [ ] Waybar **pulse** click → pavucontrol floats.
35. [ ] Waybar **network** click → nm-connection-editor floats.

## Gate H — Optional / long / multi-monitor (SKIP if N/A)

36. [ ] **Super+SHIFT+E** exits session; Super+M alone does **nothing**.
37. [ ] Volume keys / mute work (`wpctl`); brightness keys best-effort on VM.
38. [ ] Multi-monitor: Super+period / Super+comma; wallpaper on **all** outputs.
39. [ ] Idle (~10 min): session **locks** before DPMS blank (hypridle ladder).

---

**Minimum for Wave 2 PASS:** items **1–35** all PASS (36–39 SKIP only with reason).

## Idle ladder (reference)

Manual lock path (same as idle @600): **Super+SHIFT+L** → `loginctl lock-session` → hypridle `lock_cmd` (`pidof hyprlock || hyprlock`). Do not expect a direct `hyprlock` keybind.

| Seconds | Action |
|--------:|--------|
| 300 | dim (`brightnessctl` best-effort) |
| 600 | lock (`loginctl lock-session`) |
| 630 | DPMS off |
| 1200 | suspend |

## Sign-off

| Field | Value |
|-------|-------|
| Image / commit | |
| Tester | |
| Date (UTC) | |
| Result | PASS / FAIL |
| Notes | |
