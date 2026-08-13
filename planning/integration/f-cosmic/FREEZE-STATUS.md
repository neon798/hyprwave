# COSMIC freeze / validation status

| Item | Result | Notes |
|---|---|---|
| `check-vendor-paths.sh` | **PASS** (exit 0) | 11 themes, vendor Background/favorites/Mode |
| Dock favorites (6) | **PASS** | neonwolf, flatarcade, Ghostty, CosmicFiles, hyprwave-theme, CosmicSettings |
| Mode `is_dark` | **PASS** | vendor `true` |
| Wallpaper vendor key | **PASS** | `/usr/share/backgrounds/hyprwave/default.png` + repo PNG |
| `disk_config/iso-cosmic.toml` bootc ref | **PASS** | `ghcr.io/neon798/hyprwave-cosmic:latest` |
| Declutter (no cosmic-store) | **PASS** | Image inspect: package not installed |
| Display manager | **PASS** | cosmic-greeter (not SDDM) |
| Local image inspect | **PASS** | See [IMAGE-INSPECT.md](./IMAGE-INSPECT.md) — `189340691cc7` · ~10.1 GB · no SDDM |
| Support pack index | **PASS** | [README.md](./README.md) |
| Integrator checklist | **PASS** | [INTEGRATOR-CHECKLIST.md](./INTEGRATOR-CHECKLIST.md) · F-W4-001 merge-prep |
| Vendor tree file count | 49 files under `build_files/usr/share/cosmic/` | AppList, Background, Dark, Builder, Mode |
| themegen `target/` | **not committed** | [REGENERATE.md](./REGENERATE.md) |

**Stamped:** 2026-08-13 · lane `lane/f-cosmic` · task **F-W5-001**  

F-W5-001 post-merge: `lane/f-cosmic` ff to `origin/main` (`07be046`);
`check-vendor-paths.sh` exit **0** (11 themes, favorites/Mode/wallpaper). No
vendor or ISO edits. Prior F-W4-001: INTEGRATOR-CHECKLIST merge-prep; greeter ≠
SDDM; host image id `189340691cc7`.

VM/ISO interactive SESSION-SMOKE remains integrator-side for greeter GUI; host
image-inspect rows (#48–#56) in [SESSION-SMOKE.md](./SESSION-SMOKE.md) and the
re-runnable card in [IMAGE-INSPECT.md](./IMAGE-INSPECT.md). **No SDDM** on COSMIC
([GREETER.md](./GREETER.md)).