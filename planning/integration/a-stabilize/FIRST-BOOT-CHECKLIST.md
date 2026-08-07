# First-boot checklist (VM / install validation)

Purpose: prove the **existing** Hyprwave image is usable after login.
This is an operator checklist for Model A / integrator — not end-user INSTALL.md
(that belongs to Model B).

## Build artifacts to validate

| Variant   | Local build              | Disk / ISO helpers              |
|-----------|--------------------------|---------------------------------|
| Hyprland  | `just build`             | `just build-qcow2`, `just build-iso` |
| COSMIC    | `just build-cosmic`      | `just run-vm-qcow2-cosmic`, `just build-iso-cosmic` |

Full dual-variant build is **integrator-owned** after lane merges. Lane A only
requires pins + static checks; use this list when a machine is free.

## Pre-flight (host)

- [ ] `just lint` and `just check` clean
- [ ] `grep -n 'releases/latest' build_files/build.sh` empty
- [ ] Image built: `just build hyprwave latest` and/or `just build-cosmic`
- [ ] Optional VM: `just run-vm-qcow2` (needs sudo + KVM)

## GHCR public pull (status snapshot)

Recorded during lane A stabilize (2026-08-06). **Does not block other lanes.**

| Image | Result | Notes |
|-------|--------|-------|
| `ghcr.io/neon798/hyprwave:latest` | **FAIL** | `unauthorized` / cannot pull without auth — package may be private or unpublished |
| `ghcr.io/neon798/hyprwave-cosmic:latest` | **FAIL** | `403 Forbidden` on bearer token — same |

Action for maintainer (not this lane): make packages public (or document auth),
confirm CI push on `main` succeeds, then re-check anonymous pull.

Local-only validation remains valid: build from this tree and boot a qcow2/ISO.

## Hyprland first boot

1. [ ] Greeter shows (SDDM with Hyprwave theme)
2. [ ] Create / log in as a **new** user (skel only applies once)
3. [ ] Hyprland session starts; wallpaper via hyprpaper (not swaybg)
4. [ ] Waybar visible; mako notifications work (test with `notify-send test`)
5. [ ] Terminal: Ghostty opens (default Super+Enter or equivalent keybind)
6. [ ] Launcher: Walker via Super+D / Super+Space; Super+R runner mode
7. [ ] File manager: Yazi opens (`yazi` in terminal or desktop entry via Ghostty)
8. [ ] Browser: Neonwolf launches and loads a page
9. [ ] App store: FlatArcade opens in Ghostty; Flathub remote present
10. [ ] Theme switch: `hyprwave-theme` lists themes; switch and live-reload UI
11. [ ] Network: NetworkManager online; `podman` socket enabled if expected
12. [ ] Optional: `bootc status` shows the booted image ref

## COSMIC first boot

1. [ ] cosmic-greeter (not SDDM)
2. [ ] COSMIC session starts with Hyprwave vendor defaults (dock / bg / theme keys)
3. [ ] Ghostty available; Yazi skel present for new users
4. [ ] Neonwolf + FlatArcade desktop entries work
5. [ ] `hyprwave-theme` applies COSMIC `cosmic/config` + wallpaper for a theme

## Pin regression checks (image contents)

On a running system or `podman run --rm -it localhost/hyprwave:latest bash`:

```bash
# Versions should match build_files/versions.env pins used at build time
yazi --version
/usr/bin/neonwolf --version 2>/dev/null || true
flatarcade --version 2>/dev/null || flatarcade -V 2>/dev/null || true
test -x /usr/bin/yazi && test -x /usr/bin/neonwolf && test -x /usr/bin/flatarcade
test -d /usr/lib/neonwolf   # extracted AppImage tree
```

Build-time failure modes to watch on the next full build:

- curl 404 after a bad pin URL
- `sha256sum -c` failure if asset rotated under the same tag (rare) or pin typo

## CI sanity (no code change expected in lane A unless broken)

Workflows already matrix both variants:

- `.github/workflows/build.yml` — `matrix.de: [hyprland, cosmic]`
- `.github/workflows/build-disk.yml` — hyprland qcow2/iso + cosmic iso

Lane A inspected both; no structural fix required for the matrix. Revisit only
if CI starts failing for unrelated reasons after merge.

## Handoff notes for integrator

- Pins: `build_files/versions.env` + download block in `build_files/build.sh`
- Bump process: `planning/integration/a-stabilize/BUMP.md`
- Models C/D must **not** reintroduce `/releases/latest`; use snippets only
- After merge: run dual `just build` / `just build-cosmic`, then optional VM path
