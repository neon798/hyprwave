# Justified vendor / ISO fixes (F-W1-001)

## 1. `com.system76.CosmicTheme.Mode/v1/is_dark` (new)

**Change:** Ship vendor default `true`.

**Why:** `hyprwave-theme` already writes this key under `~/.config/cosmic/` on every `set`, so switcher users get an explicit dark Mode. First-boot users only had Dark theme *component* keys (`CosmicTheme.Dark/is_dark`) without the Mode schema. Aligning vendor Mode with Dark avoids a class of “looks light until Settings is opened” reports and matches session-smoke expectation #10.

**Risk:** Low — RON bool, same shape as switcher; user config still overrides.

## 2. Dock favorites order (`CosmicAppList/v1/favorites`)

**Change:** Reorder to:

1. `neonwolf`
2. `flatarcade`
3. `com.mitchellh.ghostty`
4. `com.system76.CosmicFiles`
5. `hyprwave-theme` (intentional extra)
6. `com.system76.CosmicSettings`

**Why:** Same six IDs as before (all F-W1-001 required apps + theme switcher). New order groups Hyprwave “content” apps (browser → store → terminal) before COSMIC Files, then theme tooling, then Settings — clearer first-run story for FlatArcade replacing cosmic-store.

**Not a removal:** CosmicFiles / CosmicSettings remain pinned.

## 3. `disk_config/iso-cosmic.toml` documentation

**Change:** Header comments only — image name (`hyprwave-cosmic`), GHCR ref, `just build-iso-cosmic`, kickstart intent vs `iso.toml`, module set summary.

**Why:** Task requires ISO review + kickstart-like notes; the sole functional line (`bootc switch … hyprwave-cosmic:latest`) was already correct and is unchanged.

## Explicit non-changes

| Item | Reason |
|---|---|
| Wallpaper path | Already points at staged `/usr/share/backgrounds/hyprwave/default.png` |
| Theme hex seeds | Already match `#15052e` / `#ff2d95` / `#e0e0ff` / `#b967ff` / `#00f0ff` |
| Theme `name` `"hyprwave-dark"` | Intentional vs pack name `"hyprwave"` |
| `build.sh` cosmic arm | Correct deploy order, greeter enable, declutter; no edit needed (no HANDOFF) |
| Greeter skin | No stable vendor API; documented in GREETER.md |
| themegen `target/` | Not committed |
