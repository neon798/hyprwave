# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Hyprwave is a **bootc (bootable container) image** for an immutable, Fedora Atomic–based Linux
distribution that ships Hyprland as its desktop. There is no application source code: the "build"
produces an OS image. The repo is a customized fork of the Universal Blue `image-template`.

A `DE` build-arg (default `hyprland`) selects the variant at build time. `DE=cosmic` produces
`hyprwave-cosmic` (official Fedora COSMIC group + cosmic-greeter, minimal shared skel + Hyprwave
synthwave theme as system default). The Containerfile uses a `de-${DE}` stage alias so the
`hyprbuilder` stage (and its heavy toolchain) is only pulled in for the Hyprland variant.
`build_files/build.sh` dispatches on `case "$DE"`. Vendor defaults for COSMIC (dock favorites,
background, theme keys) live under `build_files/usr/share/cosmic/` and are copied in the cosmic
case after package installs (overrides Fedora's cosmic-config-fedora layer).

The image is defined declaratively by three layers:
1. **`Containerfile`** — sets the base image (`ghcr.io/ublue-os/base-main`) and runs the build script.
2. **`build_files/build.sh`** — installs packages, enables services, deploys dotfiles. This is the
   single source of truth for what the OS contains.
3. **`build_files/etc/skel/`** — default user dotfiles, copied into `/etc/skel/` so every new user
   gets them on first login.

## Build & test commands

The `Justfile` orchestrates everything via Podman. Image name defaults to `image-template`
(override with `IMAGE_NAME`); CI sets it to the repo name (`hyprwave`).

```bash
just build                      # Build the container image with Podman
just build hyprwave latest      # Build with explicit name:tag
just build-cosmic               # Build the COSMIC variant (DE=cosmic)

just build-qcow2                # Build a bootable VM disk image (via bootc-image-builder, needs sudo)
just build-iso                  # Build an installable ISO
just build-iso-cosmic           # COSMIC ISO (disk_config/iso-cosmic.toml)
just run-vm-qcow2               # Build (if needed) and boot the image in a browser-based QEMU VM
just run-vm-qcow2-cosmic        # Same for COSMIC qcow2
just rebuild-qcow2              # Force a fresh container build, then build the VM image

just lint                       # shellcheck all *.sh
just format                     # shfmt --write all *.sh
just check                      # Verify Justfile formatting
just clean                      # Remove build artifacts and output/
```

There is no unit-test suite. Validation is `bootc container lint` (run automatically as the last
step of both `Containerfile` and `Dockerfile.overlay`) plus booting the image in a VM.

VM image builds (`build-*`, `run-vm-*`) require `sudo`/rootful Podman and KVM; the plain `just build`
does not.

## Fast iteration on dotfiles

`Dockerfile.overlay` rebuilds **only** the `/etc/skel` dotfiles and `/usr/share/hyprwave` assets on
top of an already-built `localhost/hyprwave:latest`. Use it to test config changes without paying
for a full base rebuild:

```bash
podman build -f Dockerfile.overlay -t hyprwave:latest .
```

Note: `/etc/skel` only applies to **newly created** users. Changing a dotfile here does not update
existing users' `~/.config`.

## How changes map to the image

- **Add/remove a package** → edit the `dnf5 install` lists in `build_files/build.sh`. Packages from
  COPRs (e.g. Hyprland from `ashbuk/Hyprland-Fedora`, Ghostty from `scottames/ghostty`) require the
  COPR to be enabled before the install and **disabled again afterward** (see the top and bottom of
  `build.sh`) so it doesn't leak into the final image. Use `DE=...` or the `case "$DE"` arms to
  keep packages variant-specific. For COSMIC declutter use `dnf5 remove -y --no-autoremove` (plain
  remove can cascade and delete panel/settings/portal).
- **Enable a service / set the display manager** → `systemctl enable` lines and the
  `display-manager.service` symlink in `build.sh` (different per `case "$DE"`).
- **Change desktop defaults** → edit files under `build_files/etc/skel/.config/`. The Hyprland config
  is split: `hyprland.conf` only `source`s the other `hypr/*.conf` files (envs, monitors, input,
  looknfeel, bindings, autostart) — edit the relevant fragment, not the top-level file.
  COSMIC variant only receives a ghostty/yazi skel subset. For COSMIC dock favorites, wallpaper
  and theme keys edit the files under `build_files/usr/share/cosmic/` (the vendor-default layer).
- **Themes** → store at `build_files/usr/share/hyprwave/themes/<name>/` (whole-file components:
  hypr/ghostty/waybar/walker/mako/wallpapers, cosmic/config, optional sddm). Skel reaches the active
  theme via `~/.config/hyprwave/theme` (absolute indirection symlink) plus relative per-app symlinks
  on Hyprland. Switcher `build_files/usr/bin/hyprwave-theme` ships on **both** variants: Hyprland
  live-reloads compositor UI; COSMIC copies `cosmic/config/` into `~/.config/cosmic/` + wallpaper.
  Regenerate COSMIC key trees with `planning/bin/generate-cosmic-themes.sh`. To add a theme: new dir
  under the themes store with the same layout + regenerate cosmic/config.
- **Change the base OS** → the `FROM` line in `Containerfile`. Other Universal Blue / Fedora / CentOS
  bootc bases are listed in comments there.
- **Variant (Containerfile / CI)** → `ARG DE`, `FROM de-${DE}` final stage, and the two-image matrix
  in `.github/workflows/build*.yml` (plus `iso-cosmic.toml`). The hyprbuilder stage is skipped for
  cosmic (podman skips unused stages). The cosmic case also deploys `/usr/share/cosmic/` assets
  after package install/remove steps.

## CI / release

`.github/workflows/build.yml` builds and pushes the image to `ghcr.io/<owner>/hyprwave` on every push
to `main`, on a daily schedule (10:05 UTC), and on dispatch. Pull requests build but do **not** push
or sign. Images are signed with Cosign (key in the `SIGNING_SECRET` repo secret; public key expected
at `cosign.pub`). `.github/workflows/build-disk.yml` builds disk images. GitHub Action SHAs are pinned
and updated by Renovate (`.github/renovate.json5`).

When editing the published-image metadata or description, note the workflow ignores README-only pushes
(`paths-ignore: '**/README.md'`).

## Walker (app launcher)

Walker is the application launcher, configured in `build_files/etc/skel/.config/walker/`:

- **Theme**: Custom `hyprwave` theme with Omarchy-clean structure (layout.xml + style.css)
- **Config**: `config.toml` defines providers (desktopapplications, websearch, calc) and prefixes (`/` providerlist, `.` files, `:` symbols, `=` calc, `@` websearch, `$` clipboard)
- **Autostart**: `walker.desktop` in `.config/autostart/` starts the gapplication service on login
- **Systemd override**: `restart.conf` ensures walker auto-restarts if it crashes
- **Layer rule**: `windowrules.conf` disables animations for walker namespace

Key bindings in `bindings.conf`:
- `Super+D` / `Super+Space`: Launch walker (default providers)
- `Super+R`: Launch walker with runner prefix (`--prefix ">"`)

The walker service is managed by systemd user units. After config changes, restart with `systemctl --user restart app-walker@autostart.service`.
