# Model F Work Log

(append only)

## 2026-08-07 — F-W1-001 COSMIC vendor-default audit

- Branch: `lane/f-cosmic` from `origin/main`
- Deliverables:
  - `planning/integration/f-cosmic/VENDOR-INVENTORY.md` (49 vendor keys; palette hex↔RON)
  - `planning/integration/f-cosmic/SESSION-SMOKE.md` (≥12 first-login checks)
  - `planning/integration/f-cosmic/GREETER.md` (DM expectations + known greeter limits)
  - `planning/integration/f-cosmic/REGENERATE.md` (themegen; no `target/` commits)
  - `planning/integration/f-cosmic/VENDOR-FIXES.md` (justification log)
- Vendor fixes:
  - Added `com.system76.CosmicTheme.Mode/v1/is_dark` = true
  - Reordered AppList favorites (same six IDs; FlatArcade earlier)
- ISO: `disk_config/iso-cosmic.toml` header comments only; bootc ref already `hyprwave-cosmic:latest`
- build.sh: **no edit** — cosmic arm already correct (greeter, declutter `--no-autoremove`, wallpaper copy, vendor cp). Choice: leave build.sh; document only.
- Forbidden paths untouched (Hyprland skel, pins, duress, assistant).

## 2026-08-07 — F-W1-002 Theme-store COSMIC audit + wallpaper proofs

- Branch: `lane/f-cosmic`
- Deliverables:
  - `planning/integration/f-cosmic/THEME-COSMIC-MATRIX.md` (11/11 packs; path proofs; spot-checks)
  - `planning/integration/f-cosmic/check-vendor-paths.sh` (exit 0 on full tree)
  - SESSION-SMOKE.md items 23–32 (theme switch / wallpaper / scene)
  - GREETER.md F-W1-002 branding vs greeter capabilities
  - REGENERATE.md note: packs stay Dark+Builder only
- Findings:
  - Vendor Background path OK; source PNG present (SHA matches hyprwave pack default.png)
  - Theme packs intentionally omit Mode/Background/AppList — switcher writes Mode+Background; dock stays vendor
  - No config file fixes required; themegen not re-run
- Forbidden paths untouched.

## 2026-08-07 — F-W1-003 Declutter / ISO / FlatArcade smoke

- Branch: `lane/f-cosmic`
- Deliverables:
  - `planning/integration/f-cosmic/DECLUTTER.md`
  - `disk_config/iso-cosmic.toml` final operator notes (kickstart ref unchanged)
  - SESSION-SMOKE.md items 33–47
  - GREETER.md day-1 COSMIC vs Hyprland one-pager
  - check-vendor-paths.sh: favorites flatarcade/neonwolf/hyprwave-theme + wallpaper story
- build.sh: **no edit** (read-only audit)
- Forbidden paths untouched.

## 2026-08-07 — F-W1-004 Pre-merge COSMIC freeze

- Branch: `lane/f-cosmic`
- Deliverables:
  - `planning/integration/f-cosmic/INTEGRATOR-CHECKLIST.md`
  - `planning/integration/f-cosmic/README.md` (doc index)
  - `planning/integration/f-cosmic/FREEZE-STATUS.md` (validation stamp)
- Validation: `check-vendor-paths.sh` exit 0; iso-cosmic bootc → hyprwave-cosmic:latest
- No build_files/usr/share/cosmic or build.sh changes (already frozen content)
- Forbidden paths untouched.
