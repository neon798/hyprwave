# COSMIC image inspect card (host)

Durable, copy-paste checks for `hyprwave-cosmic` after a local rebuild.
Does **not** replace greeter/session GUI smoke ([SESSION-SMOKE.md](./SESSION-SMOKE.md),
[GREETER.md](./GREETER.md)); catches packaging regressions early.

| Field | Value |
|---|---|
| Image ref (local) | `localhost/hyprwave-cosmic:latest` |
| Published ref | `ghcr.io/neon798/hyprwave-cosmic:latest` |
| ISO bootc switch | `disk_config/iso-cosmic.toml` → same GHCR ref |
| Last host stamp | **2026-08-13** · task **F-W3-001** (reconfirm; card from F-W2-002) |
| Local image id | `189340691cc7…` (full: `189340691cc79213c82e0f6649f884e96b6eedb0ece5c1c706a1f7ce1c9aa6ba`) |
| Digest | `sha256:a9ca6920971a9c4f8b17ba7faa64f6d618fdd9e3e6890b7321be5b81b0fb4dfa` |
| Created | `2026-08-13T03:22:53Z` |
| Size | ~10.1 GB (`10060284618` bytes) |

**COSMIC display manager is `cosmic-greeter` only.** Do **not** claim SDDM on this
variant ([GREETER.md](./GREETER.md)). SDDM/hyprwave theme is Hyprland-only.

---

## 0. Host pre-check (repo tree)

```bash
# From repo root (lane/f-cosmic or main with f-cosmic pack)
bash planning/integration/f-cosmic/check-vendor-paths.sh
# must exit 0 (fail=0)

rg 'hyprwave-cosmic:latest' disk_config/iso-cosmic.toml
```

---

## 1. Image present?

```bash
podman image exists localhost/hyprwave-cosmic:latest \
  && echo PASS: image present \
  || { echo SKIP: localhost/hyprwave-cosmic:latest missing — rebuild with just build-cosmic; exit 0; }

podman image inspect localhost/hyprwave-cosmic:latest \
  --format 'Id={{.Id}}
Digest={{.Digest}}
Created={{.Created}}
Size={{.Size}}
RepoTags={{.RepoTags}}'
```

**If the tag is missing:** record **SKIP** in WORK_LOG / FREEZE-STATUS — do **not**
fail the lane. Re-run after `just build-cosmic` (or equivalent).

---

## 2. Copy-paste container inspect (primary)

```bash
podman run --rm --entrypoint bash localhost/hyprwave-cosmic:latest -lc '
set -e
# Declutter: store/edit/player/wallpapers must be absent
rpm -q cosmic-store 2>&1 | grep -q "not installed" && echo PASS: no cosmic-store
rpm -q cosmic-edit 2>&1 | grep -q "not installed" && echo PASS: no cosmic-edit
rpm -q cosmic-player 2>&1 | grep -q "not installed" && echo PASS: no cosmic-player
rpm -q cosmic-wallpapers 2>&1 | grep -q "not installed" && echo PASS: no cosmic-wallpapers

# Session / greeter present
rpm -q cosmic-greeter ghostty cosmic-session cosmic-comp && echo PASS: greeter+session+ghostty

# Display manager → cosmic-greeter (NOT SDDM)
readlink -f /etc/systemd/system/display-manager.service | grep -q cosmic-greeter \
  && echo PASS: DM=cosmic-greeter
systemctl is-enabled cosmic-greeter.service | grep -qx enabled && echo PASS: greeter enabled
test ! -e /usr/lib/systemd/system/sddm.service && echo PASS: no SDDM unit

# FlatArcade + theme GUI + Neonwolf
command -v flatarcade neonwolf hyprwave-theme hyprwave-theme-gui >/dev/null \
  && echo PASS: flatarcade neonwolf hyprwave-theme(-gui)
test -f /usr/share/applications/flatarcade.desktop \
  && test -f /usr/share/applications/neonwolf.desktop \
  && test -f /usr/share/applications/hyprwave-theme.desktop \
  && echo PASS: desktop files

# Vendor favorites / Mode / wallpaper
grep -q flatarcade /usr/share/cosmic/com.system76.CosmicAppList/v1/favorites \
  && echo PASS: favorites include flatarcade
grep -qx true /usr/share/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark \
  && echo PASS: is_dark=true
test -f /usr/share/backgrounds/hyprwave/default.png && echo PASS: wallpaper PNG
grep -q /usr/share/backgrounds/hyprwave/default.png \
  /usr/share/cosmic/com.system76.CosmicBackground/v1/all \
  && echo PASS: Background key → staged PNG
'
```

### Expected PASS lines (all)

```
PASS: no cosmic-store
PASS: no cosmic-edit
PASS: no cosmic-player
PASS: no cosmic-wallpapers
PASS: greeter+session+ghostty
PASS: DM=cosmic-greeter
PASS: greeter enabled
PASS: no SDDM unit
PASS: flatarcade neonwolf hyprwave-theme(-gui)
PASS: desktop files
PASS: favorites include flatarcade
PASS: is_dark=true
PASS: wallpaper PNG
PASS: Background key → staged PNG
```

### Expected vendor favorites (exact order)

```json
[
    "neonwolf",
    "flatarcade",
    "com.mitchellh.ghostty",
    "com.system76.CosmicFiles",
    "hyprwave-theme",
    "com.system76.CosmicSettings",
]
```

Dump with:

```bash
podman run --rm --entrypoint cat localhost/hyprwave-cosmic:latest \
  /usr/share/cosmic/com.system76.CosmicAppList/v1/favorites
```

---

## 3. Recorded run (2026-08-13 · F-W2-002 + F-W3-001 reconfirm)

Image: `localhost/hyprwave-cosmic:latest` · id `189340691cc7` · digest
`sha256:a9ca6920971a9c4f8b17ba7faa64f6d618fdd9e3e6890b7321be5b81b0fb4dfa` ·
created `2026-08-13T03:22:53Z` · ~10.1 GB.

| Check | Expected | F-W2-002 | F-W3-001 reconfirm |
|---|---|---|---|
| Image present | tag exists | **PASS** | **PASS** (same id) |
| `cosmic-store` / edit / player / wallpapers | not installed | **PASS** | **PASS** |
| `cosmic-greeter` + `ghostty` + session/comp | installed | **PASS** (greeter 1.5.0-1.fc44) | **PASS** |
| `display-manager.service` | → `cosmic-greeter.service` | **PASS** | **PASS** |
| `cosmic-greeter.service` | enabled | **PASS** | **PASS** |
| SDDM unit | absent | **PASS** | **PASS** (no SDDM required) |
| FlatArcade | binary + desktop | **PASS** | **PASS** |
| Neonwolf | binary + desktop | **PASS** | **PASS** |
| Theme GUI | `hyprwave-theme` / `hyprwave-theme-gui` + desktop | **PASS** | **PASS** |
| Favorites | six IDs (includes flatarcade, hyprwave-theme) | **PASS** | **PASS** |
| Mode `is_dark` | `true` | **PASS** | **PASS** |
| Wallpaper | PNG staged; Background Path key | **PASS** | **PASS** |
| `check-vendor-paths.sh` | exit 0 | **PASS** (fail=0) | **PASS** (fail=0) |

F-W3-001 host snippet (reconfirm):

```
PASS: no cosmic-store
PASS: greeter+ghostty
PASS: DM=cosmic-greeter
PASS: no SDDM unit
PASS: flatarcade neonwolf hyprwave-theme-gui
PASS: favorites
PASS: is_dark
PASS: wallpaper
```

ISO operator path: `just build-iso-cosmic` → `disk_config/iso-cosmic.toml`
(DM = cosmic-greeter, not SDDM; GHCR ref not assumed public).

---

## 4. Cross-links

| Doc | Role |
|---|---|
| [SESSION-SMOKE.md](./SESSION-SMOKE.md) | Guest GUI smoke; host image rows #48–#56 point here |
| [GREETER.md](./GREETER.md) | DM = cosmic-greeter; **no SDDM** on COSMIC |
| [FREEZE-STATUS.md](./FREEZE-STATUS.md) | Validation stamp table |
| [DECLUTTER.md](./DECLUTTER.md) | Why cosmic-store is removed (`--no-autoremove`) |
| [check-vendor-paths.sh](./check-vendor-paths.sh) | Repo-side vendor/theme sanity |

---

## 5. After next rebuild

1. Re-run §0 + §1 + §2 against the new tag/id.
2. Update the table in §3 (date, image id, digest, size, PASS/SKIP).
3. Optionally stamp [FREEZE-STATUS.md](./FREEZE-STATUS.md) “Local image inspect” row.
4. Do **not** invent greeter theming work here — stock greeter face is expected.
