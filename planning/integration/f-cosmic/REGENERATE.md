# Regenerating COSMIC theme key trees

**Do not commit** `planning/bin/themegen/target/` (large Rust build artifacts).

## Theme packs (all named themes)

From repo root:

```bash
./planning/bin/generate-cosmic-themes.sh
```

- Builds `planning/bin/themegen` if missing (`cargo build --release`).
- Writes `build_files/usr/share/hyprwave/themes/<name>/cosmic/config/com.system76.CosmicTheme.Dark{,.Builder}/`.
- Palette table lives in the script (`hyprwave|15052e|ff2d95|…`).

Owned jointly with theme assets; Model F may run the generator and document results. Prefer not to bulk-churn every theme pack on this lane unless seeds change.

## System vendor defaults (`/usr/share/cosmic`)

Vendor defaults are a **separate** copy under `build_files/usr/share/cosmic/`:

| Schema | Role |
|---|---|
| `com.system76.CosmicAppList` | Dock favorites (hand-maintained) |
| `com.system76.CosmicBackground` | First-boot wallpaper path (hand-maintained) |
| `com.system76.CosmicTheme.Dark` | First-boot derived theme |
| `com.system76.CosmicTheme.Dark.Builder` | First-boot builder seeds |

After regenerating the `hyprwave` pack, to refresh vendor theme only:

```bash
# Example — after generate-cosmic-themes.sh
PACK=build_files/usr/share/hyprwave/themes/hyprwave/cosmic/config
DEST=build_files/usr/share/cosmic
rm -rf "$DEST/com.system76.CosmicTheme.Dark" "$DEST/com.system76.CosmicTheme.Dark.Builder"
cp -a "$PACK/com.system76.CosmicTheme.Dark" "$DEST/"
cp -a "$PACK/com.system76.CosmicTheme.Dark.Builder" "$DEST/"
# Keep system display name distinct from pack name:
printf '"hyprwave-dark"\n' > "$DEST/com.system76.CosmicTheme.Dark/v1/name"
# Do NOT overwrite AppList or Background unless intentionally changing favorites/wallpaper.
```

Then re-run the hex↔RON checks in `VENDOR-INVENTORY.md`.

## Single-theme themegen CLI

```bash
planning/bin/themegen/target/release/themegen \
  --name hyprwave \
  --bg 15052e --accent ff2d95 --text e0e0ff \
  --neutral b967ff --hint 00f0ff \
  --out /tmp/cosmic-out
# Writes /tmp/cosmic-out/cosmic/...
```

Schema pin: themegen depends on cosmic-theme matching COSMIC 1.x `v1` keys (see `planning/COSMIC-THEME-AND-STORE-REPLACEMENT.md`). Do not bump crate revs casually — master may emit v2 keys ignored by current Fedora COSMIC.

---

## F-W1-002 notes

- Theme packs intentionally contain **only** `CosmicTheme.Dark` + `Dark.Builder` (see `THEME-COSMIC-MATRIX.md`). Regenerating does **not** need to emit Mode, Background, or AppList into packs — `hyprwave-theme` synthesizes Mode + Background at apply time; dock favorites stay vendor-global.
- After regenerate, re-run:

  ```bash
  planning/integration/f-cosmic/check-vendor-paths.sh
  ```

- F-W1-002 did **not** re-run themegen: all 11 packs already had full 30+16 key trees; no broken wallpaper references.
