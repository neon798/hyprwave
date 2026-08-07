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

- [ ] `just lint` and `just check` clean (or note known pre-existing noise)
- [ ] `token=$(printf '%s/%s' releases latest); grep -nF "$token" build_files/build.sh build_files/versions.env` empty
- [ ] `bash planning/integration/a-stabilize/scripts/verify-pins.sh` OK (static + HEAD)
- [ ] optional: `bash planning/integration/a-stabilize/scripts/verify-pins.sh --checksum --light`
- [ ] Image built: `just build hyprwave latest` and/or `just build-cosmic`
- [ ] Optional VM: `just run-vm-qcow2` (needs sudo + KVM)

## GHCR public pull (status snapshot)

Recorded during lane A stabilize (2026-08-06). **Does not block other lanes.**
See also `RELEASE.md` for the visibility fix checklist.

| Image | Result | Notes |
|-------|--------|-------|
| `ghcr.io/neon798/hyprwave:latest` | **FAIL** | `unauthorized` / cannot pull without auth — package may be private or unpublished |
| `ghcr.io/neon798/hyprwave-cosmic:latest` | **FAIL** | `403 Forbidden` on bearer token — same |

Action for maintainer: make packages public (or document auth), confirm CI push
on `main` succeeds, then re-check anonymous pull.

Local-only validation remains valid: build from this tree and boot a qcow2/ISO.

## Out of scope (do not block first-boot “usable”)

| Item | Why out of scope |
|------|------------------|
| NVIDIA proprietary drivers / hybrid GPU | Needs physical hardware; document “not certified” only |
| Secure Boot enrollment edge cases | Distro/base dependent |
| Full theming polish | Frozen skel/themes in Wave 1–2 |
| Assistant / Duress features | Other lanes; dormant until integrator hooks |

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

## CI sanity

Workflows:

- `.github/workflows/build.yml` — job **`pin_guards`** then matrix `de: [hyprland, cosmic]`
- `.github/workflows/build-disk.yml` — hyprland qcow2/iso + cosmic iso; light pin grep step

## Handoff notes for integrator

- Pins: `build_files/versions.env` + download block in `build_files/build.sh`
- Bump process: `planning/integration/a-stabilize/BUMP.md`
- Release/GHCR: `planning/integration/a-stabilize/RELEASE.md`
- Models C/D must **not** reintroduce `/releases/latest`; use snippets only
- After merge: run dual `just build` / `just build-cosmic`, then optional VM path

---

## Pass/fail run log template

Copy a block per validation session. Fill **PASS** / **FAIL** / **SKIP** and short notes.
Do not delete historical blocks — append new ones under the template.

### Template (copy below)

```
### Run log
- Date (UTC): YYYY-MM-DD
- Operator:
- Branch / commit: (git rev-parse --short HEAD)
- Artifact: (localhost/hyprwave:latest | qcow2 path | iso path | ghcr.io/...:tag )
- Image digest: (podman image inspect -f '{{.Digest}}' …  OR  skopeo/GHCR digest; blank if N/A)
- Image ID / RepoDigest: (optional second line for local builds)
- Variant: hyprland | cosmic
- Host notes: (KVM y/n, nested, cloud VM, …)

| Check | Result | Notes |
|-------|--------|-------|
| pin grep clean (build.sh) | PASS/FAIL/SKIP | |
| verify-pins.sh (--head) | PASS/FAIL/SKIP | |
| verify-pins.sh --checksum [--light] | PASS/FAIL/SKIP | |
| image/disk build | PASS/FAIL/SKIP | |
| greeter appears | PASS/FAIL/SKIP | |
| new-user login / skel | PASS/FAIL/SKIP | |
| session + wallpaper | PASS/FAIL/SKIP | |
| Ghostty | PASS/FAIL/SKIP | |
| Walker / launcher | PASS/FAIL/SKIP | |
| Yazi | PASS/FAIL/SKIP | |
| Neonwolf | PASS/FAIL/SKIP | |
| FlatArcade + Flathub | PASS/FAIL/SKIP | |
| hyprwave-theme | PASS/FAIL/SKIP | |
| NetworkManager | PASS/FAIL/SKIP | |
| GHCR anonymous pull | PASS/FAIL/SKIP | |
| Cosign verify (digest/tag) | PASS/FAIL/SKIP | |

Overall: PASS / FAIL
Blockers for ship:
Follow-ups:
```

How to capture digest after a local build:

```bash
podman image inspect localhost/hyprwave:latest --format '{{.Digest}} {{.Id}}'
# or after pull:
podman image inspect ghcr.io/<owner>/hyprwave:latest --format '{{index .RepoDigests 0}}'
```

### Filled logs

```
### Run log
- Date (UTC): 2026-08-07
- Operator: Model A (A-W1-001)
- Branch / commit: lane/a-stabilize (task A-W1-001 deepen)
- Artifact: none (static pin validation only)
- Image digest: n/a
- Image ID / RepoDigest: n/a
- Variant: n/a
- Host notes: no VM this session

| Check | Result | Notes |
|-------|--------|-------|
| pin grep clean (build.sh) | PASS | no floating-release token |
| verify-pins.sh (--head) | PASS | all four URLs HTTP 200 |
| verify-pins.sh --checksum [--light] | PASS | --checksum --light (Yazi+FlatArcade digests) |
| image/disk build | SKIP | not required for A-W1-001 static done criteria |
| greeter appears | SKIP | needs VM |
| new-user login / skel | SKIP | |
| session + wallpaper | SKIP | |
| Ghostty | SKIP | |
| Walker / launcher | SKIP | |
| Yazi | SKIP | |
| Neonwolf | SKIP | |
| FlatArcade + Flathub | SKIP | |
| hyprwave-theme | SKIP | |
| NetworkManager | SKIP | |
| GHCR anonymous pull | FAIL | private/403 as of 2026-08-06; see RELEASE.md |
| Cosign verify (digest/tag) | SKIP | needs public pull |

Overall: static pins PASS; GHCR public pull still FAIL (maintainer visibility)
Blockers for ship: GHCR public packages; integrator dual-variant build + one VM first-boot
Follow-ups: re-run this log on qcow2 with digest filled
```

```
### Run log
- Date (UTC): 2026-08-07
- Operator: Model A (A-W1-001 deepen #2)
- Branch / commit: lane/a-stabilize (fail-closed pins + CI static guards)
- Artifact: none (static + network pin validation only)
- Image digest: n/a
- Image ID / RepoDigest: n/a
- Variant: n/a
- Host notes: scheduled tick; no VM

| Check | Result | Notes |
|-------|--------|-------|
| pin grep clean (build.sh) | PASS | build.sh + versions.env free of floating token |
| verify-pins.sh (--head) | PASS | static keys/sha/source + 4× HTTP 200 |
| verify-pins.sh --checksum [--light] | PASS | Yazi + FlatArcade + SVG digests match |
| image/disk build | SKIP | A-W1-001 done criteria are pin/CI/docs |
| greeter appears | SKIP | |
| new-user login / skel | SKIP | |
| session + wallpaper | SKIP | |
| Ghostty | SKIP | |
| Walker / launcher | SKIP | |
| Yazi | SKIP | |
| Neonwolf | SKIP | |
| FlatArcade + Flathub | SKIP | |
| hyprwave-theme | SKIP | |
| NetworkManager | SKIP | |
| GHCR anonymous pull | FAIL | still private/403; RELEASE.md maintainer fix |
| Cosign verify (digest/tag) | SKIP | |

Overall: PASS for pin pipeline; ship still blocked on GHCR public visibility
Blockers for ship: GHCR public packages; dual-variant image + one filled VM log
Follow-ups: none on lane A exclusive paths
```
