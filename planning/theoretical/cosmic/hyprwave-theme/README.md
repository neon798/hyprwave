# THEORETICAL ONLY — Hyprwave Theme for COSMIC

**THIS DIRECTORY AND ALL FILES HERE ARE FOR PLANNING REFERENCE ONLY.**

**DO NOT COPY THESE FILES INTO build_files/ OR ANY PRODUCTION LOCATION WITHOUT CLAUDE HANDOFF VERIFICATION.**

## Purpose
Example of what a Hyprwave-themed COSMIC appearance definition might look like, plus notes on deployment.

## Palette (source of truth)
From the main Hyprwave identity:

- Background: #15052e
- Foreground: #e0e0ff
- Accent/Pink: #ff2d95
- Cyan: #00f0ff
- Purple: #b967ff
- Font: JetBrains Mono (already in the base image for Hyprwave)

## How Themes Work in COSMIC (as of research 2026)
- Themes are RON files.
- System themes are typically installed to `/usr/share/cosmic/cosmic-themes/<name>/`
- Users import them in **Settings > Desktop > Appearance**.
- To make one the *default* for new users we can:
  1. Ship the .ron file in the image.
  2. Pre-populate the user's cosmic config (via /etc/skel) to select it.
  3. Optionally set wallpaper.

## Example File
See `hyprwave.ron` (synthesized from public Catppuccin + community examples + Hyprwave palette).

The exact field names and structure may need adjustment after inspecting a real Fedora COSMIC installation (`/usr/share/cosmic/...` or exported theme).

## Next Steps (theoretical)
- In cosmic branch of build.sh: mkdir + cp the .ron
- Add wallpaper copy / symlink if greeter + session should match
- Add minimal cosmic config files to skel for cosmic variant only (e.g. appearance + panel settings)
- Remove cosmic-store (see main planning doc)
- Wire FlatArcade visibility

## Verification Targets
- After boot: COSMIC Settings shows Hyprwave as active (or imported + selected).
- Colors match the rest of Hyprwave (pink/cyan dominant, deep purple bg).
- FlatArcade is the obvious software entry point.

**Again: theoretical only. No production impact.**
