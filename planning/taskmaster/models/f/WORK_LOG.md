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

## 2026-08-07 — F-W1-005 Integration-day smoke card

- Branch: `lane/f-cosmic`
- Deliverables: `INTEGRATION-DAY.md`; README index link
- Validation: `check-vendor-paths.sh` exit 0
- Forbidden paths untouched.

## 2026-08-07 — F-W1-006 Integration standby heartbeat

- Branch: `lane/f-cosmic` tip `7b19270` (freeze; no product scope)
- Self-check: `check-vendor-paths.sh` exit **0**
- Status: **standby for integration** — await Director serial merge per `planning/integration/g-qa/INTEGRATION-DAY.md`
- No product edits; no cross-lane work.

## 2026-08-07 — F-W1-HOLD refresh heartbeat

- Refreshed `planning/taskmaster/models/f/` from `origin/main` (Director reissue 06:05Z)
- Status remains **OPEN** HOLD — not marked DONE
- Freeze tip still F-W1-006 / 7b19270; standby for integration
- No product edits

## 2026-08-13 — F-W2-001 COSMIC vendor + greeter vs merged main

- Branch: `lane/f-cosmic` fast-forwarded to `origin/main` (c9b3085 tip family)
- `check-vendor-paths.sh`: **exit 0** (fail=0)
- Favorites (unchanged, match SESSION-SMOKE): neonwolf, flatarcade, com.mitchellh.ghostty,
  com.system76.CosmicFiles, hyprwave-theme, com.system76.CosmicSettings
- Mode is_dark=true; wallpaper → /usr/share/backgrounds/hyprwave/default.png
- Image inspect `localhost/hyprwave-cosmic:latest` (id 189340691cc7, ~10.1GB, created 2026-08-13T03:22Z):
  - cosmic-store: **not installed**
  - cosmic-greeter enabled; display-manager → cosmic-greeter.service
  - **no SDDM** unit
  - flatarcade, neonwolf, hyprwave-theme-gui present
  - vendor favorites + Mode + wallpaper PNG match tree
- Docs: SESSION-SMOKE #48–#56 image-inspect; GREETER reconfirm stock face; FREEZE-STATUS stamped 2026-08-13
- No build_files/usr/share/cosmic or build.sh edits required
- Forbidden paths untouched (Hyprland skel, pins, duress, assistant)

## 2026-08-13 — F-W2-002 Cosmic image inspect card

- Branch: `lane/f-cosmic` rebased onto `origin/main` (cherry-pick F-W2-001 docs 395eb13)
- Deliverable: `planning/integration/f-cosmic/IMAGE-INSPECT.md` (durable podman card)
- Cross-links: README, SESSION-SMOKE #48–#56, GREETER, FREEZE-STATUS (stamp F-W2-002)
- Re-ran inspect `localhost/hyprwave-cosmic:latest`:
  - id `189340691cc7` · digest `sha256:a9ca6920971a9c4f8b17ba7faa64f6d618fdd9e3e6890b7321be5b81b0fb4dfa`
  - ~10.1GB · created 2026-08-13T03:22:53Z
  - cosmic-store/edit/player/wallpapers: not installed
  - DM → cosmic-greeter.service (enabled); **no SDDM** unit
  - flatarcade, neonwolf, hyprwave-theme-gui + desktops present
  - favorites (6) + is_dark=true + wallpaper PNG PASS
- `check-vendor-paths.sh`: exit **0**
- No build_files/usr/share/cosmic or build.sh edits
- Forbidden paths untouched

## 2026-08-13 — F-W4-001 merge-prep checklist + vendor green

- Branch: `lane/f-cosmic` on `origin/main` + carried F-W2/F-W3 integration docs + iso-cosmic
- INTEGRATOR-CHECKLIST.md: Wave 4 host stamp table; 1.x/3.x/5.4/5.6 checked
  - check-vendor-paths exit **0**
  - greeter ≠ SDDM (docs + image)
  - ISO note current (`just build-iso-cosmic`; GHCR not public-assumed)
  - host image id **189340691cc7**
- iso-cosmic.toml: TOML_OK; F-W3-001 operator blurb unchanged (still current)
- FREEZE-STATUS stamped F-W4-001; README index note
- No build_files/usr/share/cosmic edits; forbidden paths untouched

## 2026-08-13 — F-W5-001 post-merge vendor paths

- Branch: `lane/f-cosmic` fast-forwarded `a6eff69` → `origin/main` (`07be046`)
- Waves 2–4 COSMIC already on main (merge `b52f54f`); post-merge recheck only
- `bash planning/integration/f-cosmic/check-vendor-paths.sh` → **exit 0** (fail=0)
  - wallpaper PNG + CosmicBackground path OK
  - favorites 6 IDs (neonwolf, Ghostty, CosmicFiles, CosmicSettings, flatarcade, hyprwave-theme)
  - Mode is_dark=true; Dark=30 / Builder=16 vendor keys
  - 11/11 theme packs OK
- No `build_files/usr/share/cosmic/**` or `iso-cosmic.toml` edits required
- Forbidden paths untouched

## 2026-08-13 — F-W5-001 re-sync after G-W5 on main

- Merged `origin/main` (`c712cbd`) into `lane/f-cosmic` (post G-W5 harness allowlist)
- Re-ran `bash planning/integration/f-cosmic/check-vendor-paths.sh` → **exit 0** (fail=0)
  - 11/11 themes; favorites/Mode/wallpaper OK; no product edits
- Forbidden paths untouched
