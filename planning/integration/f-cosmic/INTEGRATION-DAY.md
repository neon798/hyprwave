# Integration-day COSMIC smoke card

**One page for merge day.** Full detail lives in linked docs — do not expand this file into a second SESSION-SMOKE.

| Field | Value |
|---|---|
| Image | `hyprwave-cosmic` (`DE=cosmic`) |
| Lane | `lane/f-cosmic` |
| ISO kickstart ref | `ghcr.io/neon798/hyprwave-cosmic:latest` |
| Pack index | [README.md](./README.md) |
| Full freeze gate | [INTEGRATOR-CHECKLIST.md](./INTEGRATOR-CHECKLIST.md) |

---

## Gate A — Host (fail closed, ~30s)

```bash
planning/integration/f-cosmic/check-vendor-paths.sh   # must exit 0
rg 'hyprwave-cosmic:latest' disk_config/iso-cosmic.toml
rg 'no-autoremove.*cosmic-store' build_files/build.sh
```

| # | Pass if |
|---|---|
| A1 | Path script exit **0** (wallpaper, favorites, Mode, 11 theme packs) |
| A2 | ISO bootc ref is **`hyprwave-cosmic`**, not bare `hyprwave` |
| A3 | Declutter still uses **`--no-autoremove`** for store/edit/player/wallpapers |

**Do not regress:** re-adding `cosmic-store` / dropping `--no-autoremove` — see [DECLUTTER.md](./DECLUTTER.md).

---

## Gate B — Guest pre-flight (after `just build-cosmic` / VM or ISO)

Condensed from [SESSION-SMOKE.md](./SESSION-SMOKE.md). Mark PASS/FAIL.

| # | Check | Smoke # |
|---|---|---|
| B1 | DM → `cosmic-greeter` | 2 |
| B2 | `rpm -q cosmic-store cosmic-edit cosmic-player cosmic-wallpapers` all not installed | 3 |
| B3 | `cosmic-session` `cosmic-panel` `cosmic-settings` `ghostty` installed | 4 |
| B4 | `/usr/share/backgrounds/hyprwave/default.png` readable | 5 |
| B5 | Favorites file has six IDs incl. flatarcade + neonwolf | 6 |

---

## Gate C — Day-1 session (critical UX)

| # | Check | Smoke # |
|---|---|---|
| C1 | Login → COSMIC desktop (panel + dock + wallpaper) | 7–9 |
| C2 | Dark synthwave chrome (not stock blue) | 10 |
| C3 | Dock: Neonwolf, FlatArcade, Ghostty, Files, Settings | 11 |
| C4 | FlatArcade → Ghostty + TUI (not cosmic-store) | 33–38 |
| C5 | Neonwolf + Ghostty launch from dock | 39–40 |
| C6 | `hyprwave-theme set vaporwave` changes wallpaper/colors; favorites remain | 26–28, 46 |

Greeter not pink/synthwave → **expected** ([GREETER.md](./GREETER.md)), not a C1 fail.

---

## Gate D — Sign-off

| Field | Value |
|---|---|
| Integrator | |
| A1–A3 | ☐ |
| B1–B5 | ☐ |
| C1–C6 | ☐ |
| Lane tip | |
| Date UTC | |
| Result | ☐ ship COSMIC · ☐ block (list gate ids) |

**Order:** A → B → C → D. If A fails, stop; do not burn VM time.
