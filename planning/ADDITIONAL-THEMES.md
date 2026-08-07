# Additional Themes for Hyprwave Theme Pack

**Theory and Planning Only — Ready for Single-Command Implementation After Claude Verification**

## Goals
- Expand beyond the core Synthwave/Hyprwave theme.
- Stay true to the project's spirit: retro, neon, arcade, chill, driving/anime aesthetics.
- Support both Hyprland and COSMIC variants.
- Make it trivial to switch and set defaults.
- All new themes get full coverage:
  - Hyprland (looknfeel, borders, blur)
  - Ghostty terminal palette
  - Waybar styling
  - Walker launcher styling
  - Mako notifications
  - COSMIC .ron theme
  - SDDM greeter (via theme.conf + shared QML)
  - Consistent fonts (JetBrains Mono)
  - References to wallpapers

## Themes Included

1. **retro-arcade** — Bright 80s cabinet vibes (neon green, yellow, red on dark)
2. **cozy-harvest** — Warm, earthy, relaxing harvest / cozy farm life inspired
3. **fjord-dark** — Clean, cold, minimalist fjord-inspired dark theme
4. **touge-drive** — Night mountain pass racing / driving aesthetic with eurobeat energy (reds + cyans)
5. **vaporwave** — (Popular suggestion) Classic vapor aesthetics — pinks, teals, grids, very close cousin to synthwave
6. **highway-haze** — Late night highway driving through mist and neon reflections
7. **lunar-pulse** — Dreamy moonlit synthwave, chill and atmospheric
8. **glitch-horizon** — Glitchy retro-futurist with digital horizon lines
9. **arcade-rain** — Rainy night arcade, neon lights reflecting on wet pavement
10. **verdant-haven** — Fully immersive nature-inspired theme. 100% organic feel — no digital/synth artifacts. Earthy greens, browns, soft natural light. Includes photorealistic background options for beach, deep forest, and alpine meadow across 1920x1080 / 2560x1440 / 3840x2160.

## Single Command Readiness

Everything is prepared under:
- `planning/themes/<theme-name>/` — full source files
- `planning/bin/apply-theme-pack.sh` — the single command

After Claude reviews and approves:
```bash
cd /home/zen/hyprwave
planning/bin/apply-theme-pack.sh --apply --force
```

The script will integrate:
- All theme configs into skel
- Multiple Walker themes
- COSMIC themes into /usr/share/cosmic/...
- SDDM theme variants
- A `hyprwave-set-theme` command
- Updates to build.sh for installing the pack (for both DEs)
- Default remains "hyprwave"

## Default Behavior
- Original `hyprwave` (synthwave) remains the default for both variants.
- New themes are available to switch to.
- For COSMIC: each gets a .ron that can be set as default or imported.

## Implementation Notes (for Claude)
- Update build.sh cosmic and hyprland cases to copy the theme assets.
- For SDDM, either ship full theme dirs or use one QML + per-theme conf + background.
- Add optional THEME= build arg or post-install selection.
- Regenerate icon cache still happens.
- Keep images lean.

See `planning/themes/palettes.md` for exact color definitions.

All files are self-contained and ready.
