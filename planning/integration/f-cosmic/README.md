# Hyprwave COSMIC integration pack (`f-cosmic`)

Support and freeze documentation for the **`hyprwave-cosmic`** image (`DE=cosmic`).  
Owned by Task Master **Model F** (`lane/f-cosmic`).

**Start here for merges:** [INTEGRATION-DAY.md](./INTEGRATION-DAY.md) (one page) → [INTEGRATOR-CHECKLIST.md](./INTEGRATOR-CHECKLIST.md) (full gate)

---

## Document index

| Doc | Purpose |
|---|---|
| [INTEGRATION-DAY.md](./INTEGRATION-DAY.md) | **Merge-day one-pager:** host gates + condensed smoke + declutter do-not-regress |
| [INTEGRATOR-CHECKLIST.md](./INTEGRATOR-CHECKLIST.md) | Pre-merge freeze steps: vendor tree, ISO ref, script, smoke, do-not-regress |
| [DECLUTTER.md](./DECLUTTER.md) | Packages removed (`cosmic-store` etc.), `--no-autoremove`, must-remain list |
| [GREETER.md](./GREETER.md) | cosmic-greeter DM expectations, branding limits, day-1 vs Hyprland |
| [SESSION-SMOKE.md](./SESSION-SMOKE.md) | First-login + FlatArcade/Neonwolf/theme-switch smoke checklist |
| [THEME-COSMIC-MATRIX.md](./THEME-COSMIC-MATRIX.md) | All 11 theme packs: cosmic/config keys, wallpaper path proofs |
| [REGENERATE.md](./REGENERATE.md) | How to regenerate themegen trees; no `target/` commits |
| [VENDOR-INVENTORY.md](./VENDOR-INVENTORY.md) | Full `/usr/share/cosmic` key inventory (F-W1-001) |
| [VENDOR-FIXES.md](./VENDOR-FIXES.md) | Justified vendor/ISO changes log |
| [check-vendor-paths.sh](./check-vendor-paths.sh) | Repo-side path/favorites/theme sanity (`exit 0` required) |

---

## Related tree paths (outside this folder)

| Path | Role |
|---|---|
| `build_files/usr/share/cosmic/` | Vendor defaults (favorites, background, Dark/Mode) |
| `build_files/usr/share/hyprwave/themes/*/cosmic/` | Per-theme Dark/Builder key trees |
| `disk_config/iso-cosmic.toml` | COSMIC ISO kickstart → `ghcr.io/neon798/hyprwave-cosmic:latest` |
| `build_files/build.sh` `cosmic)` arm | Install greeter, declutter, deploy vendor layer |
| `Justfile` `build-cosmic` / `build-iso-cosmic` / `run-vm-qcow2-cosmic` | Build/boot entrypoints |

---

## Quick validation (host)

```bash
planning/integration/f-cosmic/check-vendor-paths.sh
# must exit 0

rg 'hyprwave-cosmic:latest' disk_config/iso-cosmic.toml
# kickstart bootc switch must target hyprwave-cosmic, not hyprwave
```
