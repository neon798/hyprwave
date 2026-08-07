# Integration-day card — Hyprland (E-W1-005)

One-page operator log for **post-merge VM** smoke. Full detail: [SESSION-SMOKE.md](./SESSION-SMOKE.md).  
Binds: [KEYBIND-MAP.md](./KEYBIND-MAP.md) · Residuals: [HANDOFF.md](./HANDOFF.md) · Start order: [AUTOSTART.md](./AUTOSTART.md)

**Setup:** Hyprland image · **new** test user · SDDM → Hyprland  
**Pass rule:** items **1–30** all PASS (31–36 optional)

---

## Run log (fill in)

| Field | Value |
|-------|-------|
| Date (UTC) | |
| Tester | |
| Image ref / tag | |
| Image digest (`sha256:…`) | |
| Git commit (hyprwave / skel) | |
| VM host notes | |
| Overall **1–30** | PASS / FAIL |
| Optional 31–36 | PASS / FAIL / SKIP |
| Blockers | |

---

## Condensed gate (mark P / F / S)

### A — Pre-flight
| # | Check | Result |
|---|--------|--------|
| 1 | Hyprland variant (not COSMIC-only) | |
| 2 | New user after skel install | |
| 3 | Login reaches Hyprland | |

### B — First 60s
| # | Check | Result |
|---|--------|--------|
| 4 | Wallpaper (hyprpaper, not black) | |
| 5 | Waybar visible | |
| 6 | No crash/portal spam | |
| 7 | Cursor on all outputs | |

### C — Apps & launcher
| # | Check | Result |
|---|--------|--------|
| 8 | Super+Return → Ghostty | |
| 9 | Super+T → Ghostty | |
| 10 | Super+D/Space → Walker filters apps | |
| 11 | Super+R → runner `>` | |
| 12 | Super+E → yazi | |
| 13 | Super+B → Neonwolf | |
| 14 | Super+A → FlatArcade (not Assistant) | |
| 15 | `xdg-open` → Neonwolf | |

### D — Shot / lock / theme
| # | Check | Result |
|---|--------|--------|
| 16 | Super+S → clipboard region | |
| 17 | Super+SHIFT+S → `~/Pictures` | |
| 18 | Super+SHIFT+L → lock / unlock | |
| 19 | No double hyprlock | |
| 20 | Super+SHIFT+T → float ThemeSwitcher | |

### E — Services & hygiene
| # | Check | Result |
|---|--------|--------|
| 21 | `hypridle` running | |
| 22 | `hyprpaper` + conf path OK | |
| 23 | elephant + Walker OK | |
| 24 | mako `notify-send` | |
| 25 | No wofi/rofi/swaybg | |
| 26 | `~/.config/hyprwave/theme` → pack | |
| 27 | waybar `style.css` resolves | |

### F — Window rules
| # | Check | Result |
|---|--------|--------|
| 28 | Walker no slide-in | |
| 29 | Waybar pulse → float pavucontrol | |
| 30 | Waybar network → float nm-editor | |

### G — Optional (SKIP if N/A)
| # | Check | Result |
|---|--------|--------|
| 31 | Super+SHIFT+E exits; Super+M noop | |
| 32 | Volume/mute (brightness best-effort) | |
| 33 | Multi-mon focus + wallpaper all outputs | |
| 34 | hyprpaper restart restores art | |
| 35 | Idle ~10m locks before DPMS | |
| 36 | Super+SHIFT+A inactive (bind commented) | |

---

## Quick failures

| Symptom | First look |
|---------|------------|
| No wallpaper | `pgrep hyprpaper`; `~/.config/hypr/hyprpaper.conf` |
| Empty Walker | `pgrep elephant`; restart elephant + walker |
| Super+S noop | `command -v hyprshot grim slurp` |
| Lock noop | `loginctl lock-session`; `pgrep hypridle` |
| Bar unstyled | [THEME-SYMLINKS.md](./THEME-SYMLINKS.md) |

## Sign-off

```
Overall: PASS / FAIL
Signed: _______________  Date: _______________
Notes: _______________________________________________
```
