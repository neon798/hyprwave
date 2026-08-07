# Hyprwave Themes - Palettes

Default (classic synthwave) and additional themes. All stay true to the core spirit: retro, neon, chill, driving, anime, vapor aesthetics. Use JetBrains Mono. High contrast where appropriate. Dark-first.

NOTE: Theme packs have been promoted to build_files/usr/share/hyprwave/themes/ for the switcher implementation. This palettes.md and per-theme READMEs remain here as index.

## 0. hyprwave (default - classic synthwave)
bg=#15052e
fg=#e0e0ff
pink=#ff2d95
cyan=#00f0ff
purple=#b967ff

## 1. retro-arcade (Core spirit - 80s arcade cabinets)
bg=#0f0f23
fg=#e0e0ff
green=#00ff9f
yellow=#ffea00
red=#ff3366
cyan=#00ffff
purple=#aa66ff

## 2. cozy-harvest (warm, earthy, relaxing harvest / cozy farm life inspired)
bg=#3a3228
fg=#f5e8c7
leaf_green=#8bc34a
sunset_orange=#ff9800
soft_blue=#4fc3f7
wood_brown=#a1887f
accent_pink=#e91e63   # subtle for accents

## 3. fjord-dark (clean, cold, minimalist fjord-inspired dark theme)
bg=#2e3440
fg=#eceff4
nord_blue=#5e81ac
nord_cyan=#88c0d0
nord_green=#a3be8c
nord_purple=#b48ead
nord_orange=#d08770

## 4. touge-drive (night mountain pass racing / driving aesthetic with eurobeat energy)
bg=#0c0c14
fg=#d8d8e8
racing_red=#e63946
headlight=#00b4d8
sign_yellow=#f4a261
mountain_purple=#7b2cbf
fog_gray=#9ca3af

## 5. vaporwave (Popular aesthetic - 80s/90s vapor, statues, grids, very close to synthwave spirit)
bg=#2a1a3d
fg=#f0d0ff
vapor_pink=#ff71ce
vapor_teal=#01cdfe
vapor_purple=#b967ff
vapor_yellow=#fffb96
grid_cyan=#7b68ee

## 6. highway-haze (late night highway driving through mist and neon)
bg=#0a0f1c
fg=#c8d4e8
haze_pink=#c97a9e
haze_cyan=#6fa8b8
haze_purple=#5e6a8a

## 7. lunar-pulse (dreamy moonlit synth, chill atmospheric)
bg=#121a2e
fg=#d4d8f0
lunar_teal=#7ec8d9
lavender=#a89ed6
pale_cyan=#9dd4e8

## 8. glitch-horizon (sharp digital corruption — lime primary, NOT pink twin of arcade-rain)
bg=#08060c
fg=#e8ffe0
acid_lime=#a3ff3d          # primary chrome / borders / selection
glitch_magenta=#ff3d9e     # secondary / alerts
electric_cyan=#00f0ff      # tertiary spark
# UI: rounding 0, thin gaps, hard edges, lime→magenta active border

## 9. arcade-rain (wet neon arcade night — cyan chrome, pink wash, coin yellow)
bg=#0a0e18
fg=#e8e0ff
neon_cyan=#00e0ff          # primary chrome / bar edge
rain_pink=#ff4d9e          # active / selection
arcade_yellow=#ffea5e      # clock / sparks
# UI: soft rounding, heavy blur, pink→cyan active border

## 10. verdant-haven (nature inspired - fully immersive natural world)
# Deep immersive nature palette - earthy, organic, no digital feel
bg=#1f2a1f
fg=#e8e4d9
forest_green=#2d5a27
earth_brown=#5c4033
leaf_green=#3a6b3a
sky_blue=#5a8a7a
sun_gold=#c9a66b
soft_moss=#4a7c59

## Usage in configs
Each theme dir contains adapted versions of:
- hypr/looknfeel.conf
- ghostty/config (palette section)
- waybar/style.css
- walker/themes/<theme>/style.css (and shared layout if needed)
- mako/config
- cosmic/<theme>.ron
- sddm/theme.conf

Default remains the original hyprwave/synthwave.

## Switching (to be implemented)
A `hyprwave-set-theme <name>` script or env var in build.
For now, the files are ready to drop in.
