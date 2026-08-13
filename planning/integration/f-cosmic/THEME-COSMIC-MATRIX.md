# Theme-store COSMIC config matrix

**Task:** F-W1-002  
**Scope:** `build_files/usr/share/hyprwave/themes/*/cosmic/**` + system vendor `build_files/usr/share/cosmic/**`  
**Generated inventory date:** 2026-08-07  

---

## Summary

| Metric | Value |
|---|---|
| Theme packs under `themes/` | **11** |
| Packs with `cosmic/config/` | **11 / 11** |
| Dark `v1` keys per pack | **30** (matches vendor Dark) |
| Dark.Builder `v1` keys per pack | **16** (matches vendor Builder) |
| Packs with Mode / Background / AppList trees | **0** (intentional — see below) |
| Wallpaper pick resolvable without scene | **11 / 11** |

---

## Full matrix

| Theme | `cosmic/config` | Dark keys | Builder keys | Mode | Background | AppList | Wallpapers (repo) | Default pick (`hyprwave-theme`, no scene) | Seed (bg / accent / hint) |
|---|---|---:|---:|---|---|---|---|---|---|
| **hyprwave** (default pack) | yes | 30 | 16 | no* | no* | no* | `default.png` + 3 JPGs | `wallpaper-2560x1440.jpg` | `15052e` / `ff2d95` / `00f0ff` |
| arcade-rain | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `0a0e18` / `00e0ff` / `ffea5e` |
| cozy-harvest | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `3a3228` / `ff9800` / `4fc3f7` |
| fjord-dark | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `2e3440` / `5e81ac` / `88c0d0` |
| glitch-horizon | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `08060c` / `a3ff3d` / `00f0ff` |
| highway-haze | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `0a0f1c` / `c97a9e` / `6fa8b8` |
| lunar-pulse | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `121a2e` / `7ec8d9` / `9dd4e8` |
| retro-arcade | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `0f0f23` / `00ff9f` / `00ffff` |
| touge-drive | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `0c0c14` / `e63946` / `00b4d8` |
| vaporwave | yes | 30 | 16 | no* | no* | no* | 3 JPGs | `wallpaper-2560x1440.jpg` | `2a1a3d` / `ff71ce` / `01cdfe` |
| verdant-haven | yes | 30 | 16 | no* | no* | no* | 9 scene JPGs | first `wallpaper*-2560x1440.jpg` → `wallpaper-beach-2560x1440.jpg` | `1f2a1f` / `2d5a27` / `5a8a7a` |

\* **Intentional minimal set** for theme packs (not a gap):

| Schema | Where it lives | Why packs omit it |
|---|---|---|
| `com.system76.CosmicTheme.Dark{,.Builder}` | Pack `cosmic/config/` (themegen) | Theme identity (palette) |
| `com.system76.CosmicTheme.Mode` | **Vendor** first boot; **`hyprwave-theme set` writes `true` into `~/.config/cosmic/`** | Mode is session preference, not per-palette |
| `com.system76.CosmicBackground` | **Vendor** first boot (`default.png`); **switcher synthesizes `Path("<picked wallpaper>")`** | Wallpaper path is absolute filesystem path chosen at apply time |
| `com.system76.CosmicAppList` | **Vendor only** (`favorites`) | Dock pins stay global across theme switches |

Seeds: `planning/bin/generate-cosmic-themes.sh` `THEMES=(…)` table.

---

## System vendor path proofs (first-boot)

| Vendor key | Content | Repo source | Staged image path | Proof |
|---|---|---|---|---|
| `CosmicBackground/v1/all` | `Path("/usr/share/backgrounds/hyprwave/default.png")` | `build_files/usr/share/hyprwave/wallpapers/default.png` | same (copied in `build.sh` cosmic arm) | File present in repo: PNG 2560×1440, SHA-256 `5b6029a2653e82dea9e1f06b591cd1b0c81fbbb2c75cbf9443ae688cc2ed0c5e` (identical to pack `themes/hyprwave/wallpapers/default.png`) |
| `CosmicAppList/v1/favorites` | 6 desktop IDs | `build_files/usr/share/cosmic/.../favorites` | `/usr/share/cosmic/...` | Non-empty JSON array: neonwolf, flatarcade, ghostty, CosmicFiles, hyprwave-theme, CosmicSettings |
| `CosmicTheme.Mode/v1/is_dark` | `true` | `build_files/usr/share/cosmic/.../is_dark` | same | RON bool present (F-W1-001) |
| `CosmicTheme.Dark` / `.Builder` | hyprwave-dark palette | `build_files/usr/share/cosmic/...` | same | 30 + 16 keys; name `"hyprwave-dark"` (vendor display name ≠ pack `"hyprwave"`) |

**Build mapping (cosmic arm, not re-edited this task):**

```text
cp /usr/share/hyprwave/wallpapers/default.png \
   /usr/share/backgrounds/hyprwave/default.png
# Vendor CosmicBackground already points at that backgrounds path.
```

**Broken references:** none found. Vendor path is not a theme-relative symlink; it only resolves after `build.sh` stages the PNG. Repo proof = source PNG exists + path string matches staged destination.

---

## Spot-check (non-default packs)

### vaporwave

| Check | Result |
|---|---|
| `Dark/v1/name` | `"vaporwave"` |
| `Dark/v1/is_dark` | `true` |
| Accent base RGB ≈ `#ff71ce` | yes (`red: 1.0, green: 0.443…, blue: 0.807…`) |
| `window_hint` ≈ `#01cdfe` | yes |
| Mode / Background / AppList in pack | absent — intentional |
| Wallpaper | `wallpaper-{1920x1080,2560x1440,3840x2160}.jpg` all present |

### fjord-dark

| Check | Result |
|---|---|
| `name` / `is_dark` | `"fjord-dark"` / `true` |
| Accent ≈ `#5e81ac` | yes (Nord-like blue) |
| Hint ≈ `#88c0d0` | yes |
| Minimal set | Mode/Background/AppList omitted; switcher supplies Mode + Background |

### verdant-haven (scene wallpapers)

| Check | Result |
|---|---|
| `name` / `is_dark` | `"verdant-haven"` / `true` |
| Accent ≈ `#2d5a27` | yes (forest green) |
| Scenes | `beach`, `forest`, `meadow` × three resolutions |
| Default pick (no scene) | glob `wallpaper*-2560x1440.jpg` → **beach** (filesystem order) |
| Scene pick | `hyprwave-theme set verdant-haven forest` → `wallpaper-forest-2560x1440.jpg` |

---

## Coherence rules (for reviewers)

1. Every pack must ship **both** `CosmicTheme.Dark` and `CosmicTheme.Dark.Builder` with full key sets (regenerate via `REGENERATE.md` if incomplete).
2. Do **not** require Mode/Background/AppList inside packs unless product wants theme-local dock pins (currently no).
3. First-boot wallpaper = vendor Background → staged `default.png`; after `hyprwave-theme set`, user Background points at a **theme store** absolute path under `/usr/share/hyprwave/themes/<name>/wallpapers/…`.
4. Greeter does not read theme packs — see `GREETER.md`.

---

## Automation

```bash
planning/integration/f-cosmic/check-vendor-paths.sh
```

Checks vendor wallpaper source, Background path string, favorites non-empty, Mode, per-theme Dark/Builder key counts, and wallpaper pick targets.
