# COSMIC Variant: Theming + Store Replacement (Theoretical Planning)

**STATUS: IMPLEMENTED** — with four corrections found by verifying against the actual built image:
1. No `/usr/share/cosmic/cosmic-themes/` exists; vendor defaults are per-key cosmic-config trees at `/usr/share/cosmic/<schema>/v1/<key>`, which apply to all users live (no skel/first-run needed).
2. Store removal must be `dnf5 remove --no-autoremove` — plain remove cascades ~92 group packages.
3. `cosmic-term` cannot be removed (`cosmic-session` hard-requires it); Ghostty is promoted via dock favorites instead.
4. The dead Firefox dock icon was the vendor `favorites` key (`org.mozilla.firefox`); overriding that one file fixes it.
Theme keys are generated with the cosmic-theme crate pinned to the libcosmic rev from cosmic-settings epoch-1.1.0 (master emits v2 schema that COSMIC 1.1 ignores); generator lives at `planning/bin/themegen/`.

This document captures the requirements and design for:
- Applying the Hyprwave synthwave color palette as the **primary/default theme** in the COSMIC variant.
- Removing the official COSMIC Store.
- Making **FlatArcade** the default application store / software center experience.

All content is for later reference and **requires Claude handoff verification** before any code touches the main tree (build.sh, skel, Containerfile, etc.).

See `planning/README.md` for process rules.

## Corrections from actual image build (verified against `localhost/hyprwave-cosmic:latest`)
- Theme path is `/usr/share/cosmic/<schema-id>/v<N>/<key>` (no `cosmic-themes/` dir); overrides are per-key RON files after package install.
- Use `dnf5 remove -y --no-autoremove` for the 4 packages (plain remove cascades ~92 pkgs including panel/settings).
- `cosmic-term` cannot be removed (hard dep of cosmic-session).
- Dock favorites override via `com.system76.CosmicAppList/v1/favorites` (fixes the dead Firefox icon from vendor default).

---

## Problem Statement (User Report)

- The COSMIC desktop variant boots successfully (`just build-cosmic` + VM or ISO).
- However, **the theme did not carry over**. The user sees the default COSMIC theme pack.
- The built-in COSMIC Store is present (undesired).
- We want FlatArcade (our TUI Flathub manager, already shipped in the shared layer) to be the canonical "app store".
- Need a cohesive Hyprwave identity on the COSMIC side (matching SDDM, Walker, Waybar, Ghostty, etc.).

Current cosmic case in build (theoretical baseline):
```bash
cosmic)
    dnf5 install -y @cosmic-desktop-environment cosmic-greeter
    systemctl enable cosmic-greeter.service
    ln -sf .../cosmic-greeter.service ...
    mkdir -p /etc/skel/.config
    cp -r .../ghostty .../yazi ...
;;
```

No theming, no store removal, no FlatArcade integration beyond the generic `.desktop` file.

---

## Goals

1. **Hyprwave as default theme** on COSMIC:
   - Primary / default appearance uses Hyprwave palette.
   - Consistent with existing Hyprwave assets (wallpaper, fonts, 8-bit/synthwave aesthetic).

2. **Remove COSMIC Store**:
   - `cosmic-store` package is not present in the final image.
   - No launcher entry for it.

3. **FlatArcade is the app store**:
   - Prominent in launchers / menus.
   - "Software" / store actions preferably route to FlatArcade (launched in Ghostty).
   - Users get the same experience as on the Hyprland side.

4. **Login / Greeter theming** (stretch but desirable):
   - cosmic-greeter should feel on-brand (wallpaper at minimum).

5. **New user experience**:
   - Fresh users on `hyprwave-cosmic` get the theme + FlatArcade by default (via `/etc/skel` + system files).

6. **No regression for Hyprland variant**.

---

## Research Summary

**COSMIC Theming (2025-2026 era):**
- Themes are `.ron` (Rusty Object Notation) files.
- System themes live under `/usr/share/cosmic/cosmic-themes/` (or similar; community examples confirm `/usr/share/cosmic/...` patterns).
- Users import via **COSMIC Settings → Desktop → Appearance → Import**.
- Full integration: panel, dock, applets, apps, even Firefox.
- Accent color + full palette (background, text, etc.) can be defined.
- Community resources: cosmic-themes.org , Catppuccin/cosmic-desktop examples.
- Existing Hyprwave palette (authoritative):
  - bg: `#15052e`
  - fg: `#e0e0ff`
  - pink/accent: `#ff2d95`
  - cyan: `#00f0ff`
  - purple: `#b967ff`
  - Font preference: JetBrains Mono
  - Aesthetic: synthwave / 8-bit arcade (see SDDM `hyprwave` theme, Walker `hyprwave` theme).

**COSMIC Store:**
- Package name: `cosmic-store`
- Pulled in by the `@cosmic-desktop-environment` comps group.
- Can be removed post-install: `dnf5 remove -y cosmic-store || true`
- Removing it should eliminate the GUI store without breaking core DE (multiple stores are tolerated upstream).

**FlatArcade Integration:**
- Already built in shared section for all variants.
- `.desktop`: `Exec=ghostty -e flatarcade`, icon registered, hicolor cache refreshed.
- On Hyprland: launched via Walker, keybinds, autostart .desktop files.
- For COSMIC: need launcher visibility + default "app store" behavior.
- COSMIC uses its own launcher/panel; config is often in `~/.config/cosmic/` (RON files for applets, dock, etc.).
- Default apps / associations can be influenced via `mimeapps.list`.
- Pre-populating skel + system defaults for new users is the bootc-friendly approach.

**Greeter:**
- `cosmic-greeter` is explicitly installed.
- Supports wallpaper (user reports + docs).
- Theming may be more limited than the full session; wallpaper + basic colors are realistic targets.

---

## Theoretical Design

### 1. Remove COSMIC Store

In the `cosmic)` arm (after the group install):

```bash
# Remove the official COSMIC app store. FlatArcade (shared) becomes the
# software experience. Safe because the group is a "recommends" style comps
# collection; removing one leaf package is supported.
dnf5 remove -y cosmic-store || true
```

Also consider masking the .desktop if it lingers:
```bash
# Prevent any residual launcher entry
rm -f /usr/share/applications/cosmic-store.desktop || true
```

### 2. Promote FlatArcade as Default App Store

- The existing `flatarcade.desktop` (installed in shared tail) should be sufficient for discovery.
- Enhance visibility:
  - Add or override a high-priority `.desktop` or use COSMIC applet config.
  - Pre-seed a COSMIC-specific "dock" or "launcher" config that includes FlatArcade.
- For "default software center" feel:
  - Populate `/etc/skel/.config/mimeapps.list` (or cosmic equivalent) with relevant associations.
  - Optionally ship a wrapper: `/usr/bin/cosmic-store` → `exec ghostty -e flatarcade` (controversial — prefer not to fake the binary if we removed the real one).
- Recommended: Remove the store + ensure FlatArcade is the obvious choice in menus and docs. Update the "app store" narrative in README/CLAUDE during verified implementation.

**Hypothetical skel addition for cosmic** (only for new users):
```
planning/theoretical/cosmic/configs/skel/.config/cosmic/...
```
(We would copy a minimal RON config that favors our tools.)

### 3. New Hyprwave Theming for COSMIC

**Create a Hyprwave theme pack.**

- File: `hyprwave.ron` (or `hyprwave-dark.ron`)
- Install location (theoretical): `/usr/share/cosmic/cosmic-themes/hyprwave/`
- Make it the default:
  - Copy the theme file into the image for the cosmic variant.
  - Provide a default user config in `/etc/skel/.config/cosmic/` (or the correct cosmic config path) that selects the Hyprwave theme on first login.
  - Or use a one-time setup in autostart if needed.

**Palette mapping (proposed):**
- Use pink (`#ff2d95`) as the primary accent (matches Hyprwave "start" energy).
- Deep bg `#15052e` for dark mode base.
- Cyan for highlights / focus.
- Purple for secondary.
- Light fg.

We would also ship the default wallpaper into the cosmic user config so it appears.

**Greeter theming:**
- Copy the Hyprwave wallpaper into the location expected by cosmic-greeter.
- (If greeter supports full theme, point it at the new pack.)

### 4. Skel Strategy for Cosmic

Current (minimal):
- Only ghostty + yazi

Planned addition (theoretical, cosmic-only):
- GTK settings (if needed for consistency)
- A cosmic/ subdirectory with appearance + panel + dock RON files that set Hyprwave theme + include FlatArcade.
- mimeapps.list updates if useful.
- Possibly a cosmic-autostart or first-run script (careful — keep lean).

**Important:** Do **not** pollute with Hypr/Walker files. Only ghostty/yazi + cosmic-specific + shared assets (wallpapers via other means?).

Wallpapers are deployed in shared; cosmic can reference `/usr/share/hyprwave/wallpapers/default.png`.

### 5. Build Flow Impact (described only)

In `build_files/build.sh` cosmic case (after current content):

```bash
# After group + greeter
dnf5 remove -y cosmic-store || true

# ... enable services ...

# After skel ghostty/yazi copies:
# Install Hyprwave COSMIC theme (theoretical)
mkdir -p /usr/share/cosmic/cosmic-themes/hyprwave
cp /ctx/planning/.../hyprwave.ron /usr/share/cosmic/cosmic-themes/hyprwave/  # (actual path TBD)

# Pre-configure new users (theoretical)
mkdir -p /etc/skel/.config/cosmic/...
# copy appearance.ron or equivalent that selects "Hyprwave"
```

In Containerfile: no change (theme files would come from build.sh or added to build_files under a cosmic/ tree).

For ISO: already using `iso-cosmic.toml`.

### 6. Icon / Launcher Polish

- Ensure `flatarcade.svg` + cache step (already shared) works in COSMIC.
- COSMIC may prefer its own icon theme; test and possibly extend hicolor or provide cosmic-specific icons later.

---

## Theoretical Assets (under planning/theoretical/)

See the `planning/theoretical/cosmic/` directory created for this plan.

Example files to be created here (marked heavily as non-shippable):

- `hyprwave-theme/hyprwave.ron` — sample theme definition using the palette.
- `configs/skel/.config/cosmic/com.system76.CosmicTheme.Mode.ron` or similar (example structure).
- `configs/skel/.config/mimeapps.list` fragment.
- Instructions README inside the theoretical dir.

These will be written as **reference examples only**.

---

## Risks & Open Questions

- Exact paths for COSMIC system themes and user configs in Fedora 44+ cosmic package (may have moved since early alphas).
- Does removing `cosmic-store` leave any broken applets or "Software" menu items?
- How much of the greeter is themeable vs. just wallpaper?
- Will a custom .ron theme survive updates / be importable at build time?
- FlatArcade is TUI — does the user expect a more native-feeling store, or is the current "launch in terminal" philosophy acceptable on COSMIC too? (Current Hyprwave design favors it.)
- Performance / size: cosmic group is large; removing one package helps a little.
- First-login vs. system-wide default: skel only affects new users.

## Verification Plan (for when Claude implements)

1. `just build-cosmic`
2. `just run-vm-qcow2-cosmic` (or build-iso + test)
3. Boot → confirm:
   - Appearance settings show "Hyprwave" (or auto-selected) with correct colors.
   - No cosmic-store in menus or `rpm -q`.
   - Clicking "app store" / software actions launches FlatArcade in Ghostty.
   - Wallpaper from Hyprwave is used.
   - cosmic-greeter shows on-brand wallpaper/colors.
4. `bootc container lint`
5. `just lint` + any new shell bits
6. Check that DE=hyprland build is bit-identical (packages, services, skel).

## Handoff Checklist (Claude must complete before editing main)

- [ ] Read this doc + planning/README.md + TEMPLATE
- [ ] Inspect current `build.sh` cosmic case + shared FlatArcade section
- [ ] Inspect existing Hyprwave theme files (SDDM, Walker CSS, theme.conf)
- [ ] Research latest Fedora COSMIC theme paths (test build if needed)
- [ ] Design the actual .ron file + deployment method
- [ ] Decide on exact skel additions for cosmic only
- [ ] Implement safely (probably extend the cosmic) case + add files under build_files if appropriate
- [ ] Update docs (README, CLAUDE.md) surgically
- [ ] Full verification in VM + lint
- [ ] Confirm no impact on Hyprland image
- [ ] Provide handoff note back

## References

- Hyprwave palette locations: `build_files/usr/share/sddm/themes/hyprwave/theme.conf`, `Main.qml`, Walker `style.css`, AGENTS.md
- FlatArcade installation: `build_files/build.sh` (shared section)
- COSMIC theming: cosmic-themes.org, Catppuccin/cosmic-desktop (GitHub), System76 docs
- Store removal: dnf remove after group install (common pattern in this repo, e.g. firefox)

---

*End of theoretical plan. Created for reference during planning session.*
