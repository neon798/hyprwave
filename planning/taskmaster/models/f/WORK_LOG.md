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
