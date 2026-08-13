# COSMIC vendor-default inventory (Model F)

**Task:** F-W1-001  
**Tree:** `build_files/usr/share/cosmic/` → image path `/usr/share/cosmic/`  
**Deployed by:** `build_files/build.sh` `cosmic)` arm (`cp -r /ctx/usr/share/cosmic/. /usr/share/cosmic/` after RPM install)  
**Precedence:** user `~/.config/cosmic/` overrides vendor; vendor overrides Fedora `cosmic-config-fedora` layer.

Format of keys: RON (Rusty Object Notation) scalar/struct files under  
`/usr/share/cosmic/<com.system76.Schema>/v1/<key>`.

Total vendor files in repo: **49** (includes Mode `is_dark`).

---

## Deployment companion (not under this tree)

| Image path | Source in repo | Purpose |
|---|---|---|
| `/usr/share/backgrounds/hyprwave/default.png` | `build_files/usr/share/hyprwave/wallpapers/default.png` (PNG 2560×1440) | Copied in `cosmic)` arm; CosmicBackground vendor key points here |
| `/usr/share/hyprwave/themes/*/cosmic/config/` | Theme packs (themegen) | Used by `hyprwave-theme set` → user `~/.config/cosmic/` only; not first-boot vendor |

---

## 1. Dock favorites — `com.system76.CosmicAppList`

| Path | Purpose |
|---|---|
| `com.system76.CosmicAppList/v1/favorites` | RON/JSON-like string array of `.desktop` IDs pinned to the COSMIC dock/app list for every user without a local override |

### Current favorites (order = dock order)

| Desktop ID | App | Required by F-W1-001? | Notes |
|---|---|---|---|
| `neonwolf` | Neonwolf browser | **yes** | Matches `neonwolf.desktop` from shared build |
| `flatarcade` | FlatArcade (Flathub TUI) | **yes** | Store replacement; launched via Ghostty in `.desktop` |
| `com.mitchellh.ghostty` | Ghostty | **yes** | Upstream/COPR desktop ID for Ghostty |
| `com.system76.CosmicFiles` | COSMIC Files | **yes** | Official COSMIC file manager |
| `hyprwave-theme` | Hyprwave Themes GUI | intentional extra | Theme switcher; not in the minimum five, kept for discoverability |
| `com.system76.CosmicSettings` | COSMIC Settings | **yes** | System settings |

Order groups browser → store → terminal → files → theme tooling → settings (see `VENDOR-FIXES.md`).

**Verdict:** All five required favorites are present. Intentional sixth pin: `hyprwave-theme`.

**Not pinned (by design):** `cosmic-term` remains installed (session hard-dep) but is not dock-favorited so Ghostty is the promoted terminal; `cosmic-store` is removed at build time.

---

## 2. Background — `com.system76.CosmicBackground`

| Path | Purpose |
|---|---|
| `com.system76.CosmicBackground/v1/all` | Default wallpaper for output `"all"` |

### Fields (vendor `all`)

| Field | Value | Notes |
|---|---|---|
| `output` | `"all"` | Apply to every display |
| `source` | `Path("/usr/share/backgrounds/hyprwave/default.png")` | **Exists at image build** via copy from `/usr/share/hyprwave/wallpapers/default.png` |
| `filter_by_theme` | `false` | Do not swap image with theme filter |
| `rotation_frequency` | `3600` | Seconds (single path; no multi-set rotation in practice) |
| `filter_method` | `Lanczos` | Scale filter |
| `scaling_mode` | `Zoom` | Fill/crop |
| `sampling_method` | `Alphanumeric` | Matches `hyprwave-theme` apply_cosmic writer |

**Repo existence check:** `build_files/usr/share/hyprwave/wallpapers/default.png` is present (PNG, 2560×1440).  
**Image path check:** created only in the `cosmic)` case of `build.sh` (Hyprland variant does not need this alias path).

---

## 3. Dark theme (derived) — `com.system76.CosmicTheme.Dark`

Full theme applied by cosmic-settings / libcosmic. Generated historically via `planning/bin/themegen` (cosmic-theme crate) from Hyprwave hex seeds; component colors are *derived*, not hand-authored.

| Path | Purpose |
|---|---|
| `…/v1/name` | Display name string: `"hyprwave-dark"` (system default label; theme packs use short names like `"hyprwave"`) |
| `…/v1/is_dark` | `true` — dark mode |
| `…/v1/is_frosted` | `false` — solid panels (no frosted glass) |
| `…/v1/is_high_contrast` | `false` |
| `…/v1/active_hint` | Window active-hint thickness (px): `3` |
| `…/v1/gaps` | `(0, 8)` outer/inner gap pair |
| `…/v1/spacing` | Design-token spacing scale (`space_none` … `space_xxxl`) |
| `…/v1/corner_radii` | Radius tokens (`radius_0` … `radius_xl`) |
| `…/v1/palette` | Full named palette (grays, neutrals, accent_* hues) |
| `…/v1/background` | Container colors for desktop background surface |
| `…/v1/primary` | Primary container / surface colors |
| `…/v1/secondary` | Secondary container colors |
| `…/v1/accent` | Accent component state colors (base/hover/pressed/…) |
| `…/v1/accent_button` | Accent-filled button states |
| `…/v1/accent_text` | Accent text override (RON `None`/`Some`) |
| `…/v1/success` / `success_button` | Success semantic + button |
| `…/v1/warning` / `warning_button` | Warning semantic + button |
| `…/v1/destructive` / `destructive_button` | Destructive semantic + button |
| `…/v1/button` | Default button component |
| `…/v1/icon_button` | Icon button component |
| `…/v1/link_button` | Link-style button |
| `…/v1/list_button` | List row button |
| `…/v1/text_button` | Text button |
| `…/v1/text_tint` | Global text tint (seed → fg) |
| `…/v1/control_tint` | Control chrome tint |
| `…/v1/window_hint` | Focused window edge color (seed → cyan) |
| `…/v1/shade` | Overlay shade (e.g. modal dim) |

---

## 4. Dark theme builder (seeds) — `com.system76.CosmicTheme.Dark.Builder`

Builder inputs COSMIC uses to re-derive a theme in Settings. Must stay coherent with Dark keys.

| Path | Purpose | Seed / value |
|---|---|---|
| `…/v1/accent` | Accent seed RGB | pink `#ff2d95` |
| `…/v1/bg_color` | Background seed RGBA | bg `#15052e` α=1 |
| `…/v1/text_tint` | Text seed RGB | fg `#e0e0ff` |
| `…/v1/neutral_tint` | Neutral/secondary seed RGB | purple `#b967ff` |
| `…/v1/window_hint` | Window hint seed RGB | cyan `#00f0ff` |
| `…/v1/palette` | Builder palette (Dark variant name `"cosmic-dark"` + hues) | generated |
| `…/v1/active_hint` | Hint thickness | `3` |
| `…/v1/gaps` | Gap pair | `(0, 8)` |
| `…/v1/spacing` | Spacing tokens | same scale as Dark |
| `…/v1/corner_radii` | Radius tokens | same as Dark |
| `…/v1/is_frosted` | Frosted flag | `false` |
| `…/v1/destructive` / `success` / `warning` | Optional semantic seed overrides | `None` (derive) |
| `…/v1/primary_container_bg` / `secondary_container_bg` | Optional container overrides | `None` |

---

## 5. Theme mode — `com.system76.CosmicTheme.Mode`

| Path | Purpose |
|---|---|
| `com.system76.CosmicTheme.Mode/v1/is_dark` | Vendor `true` — prefer dark appearance mode on first boot (same key `hyprwave-theme` writes to user config) |

## 6. Hyprwave palette — hex vs RON floats

Canonical Hyprwave colors (docs / Walker / themes):

| Role | Hex | RON floats (approx, 0–1 sRGB) | Where in vendor tree |
|---|---|---|---|
| Background | `#15052e` | `r:0.08235 g:0.01961 b:0.18039` | Builder `bg_color`; Dark `background` base |
| Foreground / text | `#e0e0ff` | `r:0.87843 g:0.87843 b:1.0` | Builder + Dark `text_tint` |
| Accent (pink) | `#ff2d95` | `r:1.0 g:0.17647 b:0.58431` | Builder `accent`; Dark `accent*` / focus fields |
| Cyan (window hint) | `#00f0ff` | `r:0.0 g:0.94118 b:1.0` | Builder + Dark `window_hint` |
| Purple (neutral) | `#b967ff` | `r:0.72549 g:0.40392 b:1.0` | Builder `neutral_tint`; control tints |

**Verification (F-W1-001):** Builder seeds and Dark focus/accent base channels match the hex table above (float→hex round-trip exact for all five roles). Derived hover/pressed/disabled states are cosmic-theme crate outputs and intentionally differ from flat hex.

**Theme pack name note:**  
`/usr/share/cosmic/.../name` = `"hyprwave-dark"` (first-boot system identity).  
`themes/hyprwave/cosmic/config/.../name` = `"hyprwave"` (switcher pack name).  
Only the name string differs between vendor Dark tree and the `hyprwave` theme pack; colors match.

---

## 7. Declutter story (build.sh, for session identity)

Not files under this tree, but required for “what the image should contain”:

| Action | Packages | Why |
|---|---|---|
| Install | `@cosmic-desktop-environment`, `cosmic-greeter` | DE + greeter (greeter explicit) |
| Remove `--no-autoremove` | `cosmic-store`, `cosmic-edit`, `cosmic-player`, `cosmic-wallpapers` | Store→FlatArcade; edit→geany; player→mpv; wallpapers→Hyprwave; **must** use `--no-autoremove` or dnf cascades ~92 pkgs |
| Keep | `cosmic-term` | `cosmic-session` hard-requires it |
| Enable | `cosmic-greeter.service` + `display-manager.service` symlink | Login path |

---

## 8. Regeneration (no `target/` commits)

See `REGENERATE.md` in this directory.

```bash
# From repo root — rebuilds theme *packs* under build_files/usr/share/hyprwave/themes/*/cosmic/
# Does NOT automatically refresh vendor /usr/share/cosmic/ (system default stays this inventory).
./planning/bin/generate-cosmic-themes.sh
# Do not commit planning/bin/themegen/target/
```

To refresh **vendor** defaults after a palette change: run themegen for the `hyprwave` row, copy Dark + Builder trees into `build_files/usr/share/cosmic/`, set `name` to `"hyprwave-dark"`, leave AppList + Background intact, re-audit this inventory.

---

## Audit summary (F-W1-001)

| Check | Result |
|---|---|
| Favorites include Neonwolf, FlatArcade, Ghostty, CosmicFiles, CosmicSettings | **PASS** (+ hyprwave-theme) |
| Background path exists in repo and is staged in image | **PASS** |
| Dark seeds match Hyprwave hex palette | **PASS** |
| Vendor tree complete (AppList + Background + Mode + Dark + Builder) | **PASS** (49 files) |
