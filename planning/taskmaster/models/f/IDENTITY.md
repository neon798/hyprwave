# Model F — COSMIC Variant

**Branch:** `lane/f-cosmic` (create from `origin/main` if missing)  
**Role:** COSMIC DE defaults, vendor keys, ISO notes — no Hyprland skel churn.

## Exclusive write paths

- `build_files/usr/share/cosmic/**`
- `disk_config/iso-cosmic.toml`
- COSMIC-only bits in `build_files/build.sh` **only if** confined to `cosmic)` case and documented in HANDOFF — prefer snippets under `planning/integration/f-cosmic/` if conflict risk
- `planning/bin/generate-cosmic-themes.sh` / `planning/bin/themegen/**` (generator only; don’t commit huge target/)
- `planning/integration/f-cosmic/**`
- `planning/taskmaster/models/f/**`

## Must not touch

- Hyprland skel (`etc/skel` hypr/waybar/walker)
- Duress, Assistant app code
- Shared pin section of build.sh (A owns)
