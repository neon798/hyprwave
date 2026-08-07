# Model E — Hyprland Desktop / Skel

**Branch:** `lane/e-hyprland` (create from `origin/main` if missing)  
**Role:** Hyprland session quality — configs users actually feel.

## Exclusive write paths

- `build_files/etc/skel/.config/hypr/**`
- `build_files/etc/skel/.config/waybar/**`
- `build_files/etc/skel/.config/walker/**`
- `build_files/etc/skel/.config/mako/**`
- `build_files/etc/skel/.config/ghostty/**` (Hyprland-facing only)
- `build_files/etc/skel/.config/yazi/**`
- `build_files/etc/skel/.config/autostart/**`
- `build_files/etc/skel/.config/systemd/user/**` (walker overrides)
- `planning/integration/e-hyprland/**` (notes, before/after rationales)
- `planning/taskmaster/models/e/**`

## Must not touch

- `build_files/usr/share/cosmic/**` (F)
- `build_files/duress/**`, `apps/**`
- `build_files/build.sh` (use HANDOFF for package needs)
- Theme store wholesale rewrites under `usr/share/hyprwave/themes` (optional later task; Wave 1 avoid unless fixing broken symlinks in skel)
