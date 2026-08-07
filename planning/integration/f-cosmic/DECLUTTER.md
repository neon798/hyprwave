# COSMIC declutter proof (build intent)

**Task:** F-W1-003  
**Source of truth:** `build_files/build.sh` `case "$DE" in … cosmic)` arm (read-only audit; no arm rewrite this task).  
**Goal:** Document what Hyprwave deliberately strips vs what must stay so the session does not collapse.

---

## Declutter command (exact)

```bash
dnf5 remove -y --no-autoremove \
  cosmic-store cosmic-edit cosmic-player cosmic-wallpapers
```

Location: `build.sh` cosmic arm, **after** `@cosmic-desktop-environment` + `cosmic-greeter` install, **before** vendor `/usr/share/cosmic` deploy and wallpaper stage.

---

## Packages intentionally removed

| Package | Why removed | Replacement in Hyprwave story |
|---|---|---|
| `cosmic-store` | Upstream app store UX; overlaps Flatpak/Flathub story | **FlatArcade** (`flatarcade` binary + `flatarcade.desktop` → `ghostty -e flatarcade`) |
| `cosmic-edit` | Redundant editor for a minimal dock | **geany** (shared utilities install; not dock-promoted) |
| `cosmic-player` | Redundant media player | **mpv** (shared utilities) |
| `cosmic-wallpapers` | Stock Fedora/System76 wallpaper set fights brand | **Hyprwave** `/usr/share/backgrounds/hyprwave/default.png` + theme-store wallpapers |

These four are the **only** COSMIC-group removals in the cosmic arm. Shared post-`esac` cleanup also drops Firefox/xterm (all variants) — not COSMIC-specific declutter.

---

## Packages intentionally avoided / not installed

| Item | Notes |
|---|---|
| Hyprland compositor stack | Not in cosmic arm (`hyprland)` arm only) |
| Walker / elephant / waybar / mako / hyprpaper | COSMIC panel/launcher/notifications own the shell |
| SDDM as DM | cosmic-greeter is DM; SDDM theme assets may still exist in image tree but are unused as DM |
| Extra elephant plugins / COPR Hyprland | COPRs for walker/Hyprland are hyprland-arm concerns |

Shared installs that **do** ship on COSMIC: `ghostty`, Neonwolf AppImage extract, FlatArcade, `hyprwave-theme`, yazi helpers, network/desktop utilities.

---

## Packages that must remain

| Package / unit | Why |
|---|---|
| `cosmic-session` | Session entrypoint; hard dep of a working COSMIC login |
| `cosmic-comp` | Compositor |
| `cosmic-panel` | Shell chrome |
| `cosmic-settings` | Settings app; dock favorite |
| `cosmic-files` (CosmicFiles) | File manager; dock favorite |
| `cosmic-greeter` (+ `cosmic-greeter.service`) | Display manager |
| `cosmic-term` | **Kept on purpose** — `cosmic-session` hard-requires it even though Ghostty is the user-facing terminal |
| Portal / applets / other group members | Pulled by comps; do **not** autoremove them |

Smoke cross-check: SESSION-SMOKE #3 (absent), #4 (present).

---

## Critical warning: `--no-autoremove`

Plain `dnf5 remove -y cosmic-store …` (without `--no-autoremove`) treats the rest of the comps group as unused weak deps and can remove **~92 packages**, including:

- `cosmic-panel`
- `cosmic-settings`
- xdg desktop portal pieces
- other session-critical group members

**Never** drop `--no-autoremove` on this remove line. If declutter expands, add packages to the same `remove -y --no-autoremove` invocation only after verifying they are not hard deps of `cosmic-session`.

---

## Deploy order (why it matters)

1. Install `@cosmic-desktop-environment` + `cosmic-greeter`
2. Enable greeter / `display-manager.service` symlink
3. **Declutter** with `--no-autoremove`
4. Stage wallpaper + copy vendor `build_files/usr/share/cosmic/` → `/usr/share/cosmic/`
5. Skel subset (ghostty, yazi, theme indirection)

Vendor config must land **after** RPM files so Fedora `cosmic-config-fedora` does not clobber Hyprwave favorites/theme/background.

---

## Dock favorites vs removed apps

Vendor `com.system76.CosmicAppList/v1/favorites` pins:

1. `neonwolf` — not a removed RPM; AppImage launcher
2. `flatarcade` — replaces cosmic-store in UX
3. `com.mitchellh.ghostty`
4. `com.system76.CosmicFiles`
5. `hyprwave-theme`
6. `com.system76.CosmicSettings`

There is **no** favorite ID for cosmic-store / cosmic-edit / cosmic-player. Removing those packages without updating favorites would leave dead dock entries — current vendor list is aligned.

---

## Operator verification (guest)

```bash
# Must be absent
rpm -q cosmic-store cosmic-edit cosmic-player cosmic-wallpapers
# → each "package … is not installed"

# Must be present (minimum)
rpm -q cosmic-session cosmic-comp cosmic-panel cosmic-settings \
       cosmic-term cosmic-greeter ghostty

# Replacements on PATH / desktop
command -v flatarcade neonwolf ghostty hyprwave-theme
test -x /usr/lib/neonwolf/AppRun
test -f /usr/share/applications/flatarcade.desktop
test -f /usr/share/applications/neonwolf.desktop

# Wallpaper stage
test -r /usr/share/backgrounds/hyprwave/default.png
```

Repo-side (no guest): `planning/integration/f-cosmic/check-vendor-paths.sh` (favorites + wallpaper + theme keys).

---

## Explicit non-goals

- Do not remove `cosmic-term` to “force Ghostty only” — breaks session deps.
- Do not use plain `dnf remove` autoremove for declutter experiments on live images without a rollback plan.
- Declutter is **cosmic arm only**; Hyprland variant has a different package story (out of Model F exclusive paths for skel).
