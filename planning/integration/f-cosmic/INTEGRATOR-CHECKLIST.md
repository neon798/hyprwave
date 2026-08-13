# COSMIC pre-merge integrator checklist

**Task:** F-W1-004 (freeze)  
**Lane:** `lane/f-cosmic` → merge into `main` only when boxes below are satisfied  
**Image:** `hyprwave-cosmic` (`DE=cosmic`)

Use this as the single gate for “COSMIC variant is frozen enough to integrate.”  
Cross-links: [README.md](./README.md) · [DECLUTTER.md](./DECLUTTER.md) · [GREETER.md](./GREETER.md) · [SESSION-SMOKE.md](./SESSION-SMOKE.md) · [THEME-COSMIC-MATRIX.md](./THEME-COSMIC-MATRIX.md)

---

## 1. Repo automation (required before merge)

| # | Check | How | Status |
|---|---|---|---|
| 1.1 | Vendor + theme path script green | `planning/integration/f-cosmic/check-vendor-paths.sh` → **exit 0** | ☐ |
| 1.2 | Wallpaper source present | `build_files/usr/share/hyprwave/wallpapers/default.png` is PNG | ☐ (covered by 1.1) |
| 1.3 | Vendor Background path | `CosmicBackground/v1/all` → `/usr/share/backgrounds/hyprwave/default.png` | ☐ (1.1) |
| 1.4 | Dock favorites non-empty + replacements | Includes `neonwolf`, `flatarcade`, `ghostty`, CosmicFiles, CosmicSettings, `hyprwave-theme` | ☐ (1.1) |
| 1.5 | Mode dark | `CosmicTheme.Mode/v1/is_dark` = `true` | ☐ (1.1) |
| 1.6 | Theme packs coherent | 11 packs, 30 Dark + 16 Builder keys each | ☐ (1.1 + matrix) |

**Freeze stamp (F-W1-004):** `check-vendor-paths.sh` run on lane → **exit 0** (2026-08-07).

---

## 2. Vendor tree merge (`build_files/usr/share/cosmic/`)

| # | Check | How | Status |
|---|---|---|---|
| 2.1 | Schemas present | `CosmicAppList`, `CosmicBackground`, `CosmicTheme.Dark`, `Dark.Builder`, `Mode` | ☐ |
| 2.2 | Do not drop Mode | First-boot dark Mode must ship (F-W1-001) | ☐ |
| 2.3 | Favorites stay store-free | **No** `cosmic-store` desktop ID; FlatArcade is the store story | ☐ |
| 2.4 | Inventory still accurate | If keys change, update [VENDOR-INVENTORY.md](./VENDOR-INVENTORY.md) / [VENDOR-FIXES.md](./VENDOR-FIXES.md) | ☐ |
| 2.5 | Deploy order preserved | In `build.sh` cosmic arm: install → declutter → **then** `cp` vendor cosmic + wallpaper | ☐ |

---

## 3. ISO / bootc (`disk_config/iso-cosmic.toml`)

| # | Check | Expected | Status |
|---|---|---|---|
| 3.1 | Kickstart bootc ref | `ghcr.io/neon798/hyprwave-cosmic:latest` | ☐ |
| 3.2 | Not Hyprland ref | Must **not** be `ghcr.io/neon798/hyprwave:latest` | ☐ |
| 3.3 | Operator notes | Header documents image name, build (`just build-iso-cosmic`), known limits | ☐ |
| 3.4 | Anaconda modules | Storage/Runtime/Network/Security/Services/Users/Timezone on; Subscription off | ☐ |

**Confirmed F-W1-004:** kickstart line is:

```text
bootc switch --mutate-in-place --transport registry ghcr.io/neon798/hyprwave-cosmic:latest
```

---

## 4. Declutter — do not reintroduce store stack

| # | Check | Status |
|---|---|---|
| 4.1 | `build.sh` still removes with **`--no-autoremove`**: `cosmic-store` `cosmic-edit` `cosmic-player` `cosmic-wallpapers` | ☐ |
| 4.2 | **Never** plain-remove the comps group (autoremove can delete ~92 pkgs including panel/settings) | ☐ |
| 4.3 | Keep `cosmic-term` (session hard-dep) even if Ghostty is default UX | ☐ |
| 4.4 | Guest smoke: `rpm -q cosmic-store` → not installed; `command -v flatarcade` works | ☐ → [SESSION-SMOKE.md](./SESSION-SMOKE.md) #3, #33–#38 |

Details: [DECLUTTER.md](./DECLUTTER.md)

---

## 5. Session / greeter support pack

| # | Check | Doc | Status |
|---|---|---|---|
| 5.1 | First-login identity (wallpaper, dark chrome, dock) | [SESSION-SMOKE.md](./SESSION-SMOKE.md) #1–#15 | ☐ VM |
| 5.2 | FlatArcade / Ghostty / Neonwolf day-1 | SESSION-SMOKE #33–#42 | ☐ VM |
| 5.3 | Theme switch + wallpaper | SESSION-SMOKE #23–#32, #46–#47 | ☐ VM |
| 5.4 | Greeter is DM; branding limits accepted | [GREETER.md](./GREETER.md) | ☐ |
| 5.5 | Support one-pager COSMIC vs Hyprland | GREETER “Day-1” section | ☐ |

VM/ISO boots are **integration environment** checks; repo freeze requires 1.x + 3.x + 4.1–4.3 even if VM is deferred.

---

## 6. Theme store / regenerate

| # | Check | Status |
|---|---|---|
| 6.1 | Packs = Dark + Builder only (Mode/Background/AppList via vendor/switcher) | ☐ [THEME-COSMIC-MATRIX.md](./THEME-COSMIC-MATRIX.md) |
| 6.2 | No `planning/bin/themegen/target/` in git | ☐ |
| 6.3 | Regen procedure known | ☐ [REGENERATE.md](./REGENERATE.md) |

---

## 7. Forbidden / out of lane (reject PR noise)

- Hyprland skel rewrites (`build_files/etc/skel` Hyprland chrome)
- Shared pin URL ownership (Model A)
- Duress / Assistant app code
- Removing packages that break `cosmic-session`
- Re-adding `cosmic-store` without product decision + DECLUTTER update

---

## 8. Suggested merge order for integrators

1. Run `check-vendor-paths.sh` (fail closed).  
2. Diff `build_files/usr/share/cosmic/` + `disk_config/iso-cosmic.toml` + cosmic arm of `build.sh`.  
3. Confirm ISO ref string (`hyprwave-cosmic`).  
4. Skim DECLUTTER + GREETER for support FAQ.  
5. Optional: `just build-cosmic` + `just run-vm-qcow2-cosmic` and mark SESSION-SMOKE criticals.  
6. Merge `lane/f-cosmic` (or cherry-pick freeze docs + vendor if split).

---

## Sign-off

| Field | Value |
|---|---|
| Integrator | |
| Lane tip commit | |
| `check-vendor-paths.sh` | ☐ exit 0 |
| ISO ref confirmed | ☐ `hyprwave-cosmic:latest` |
| Declutter intact | ☐ `--no-autoremove` + four packages |
| Date (UTC) | |
| Result | ☐ freeze OK to merge · ☐ blocked (list section #s) |

**Model F freeze (F-W1-004):** repo-side items 1.1–1.6, 3.1–3.4, 4.1–4.3, docs index complete; VM smoke left to integrator environment.
