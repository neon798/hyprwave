# Install Hyprwave

Hyprwave is a **bootc** (bootable container) image: an immutable Fedora Atomic–based OS.
You install by **switching** an existing bootc host to the Hyprwave image, or by building
an installable **ISO** / VM disk from this repo.

Two desktop variants ship:

| Variant | Image | Display manager | Desktop |
|---------|-------|-----------------|---------|
| **Hyprland** (default) | `ghcr.io/neon798/hyprwave:latest` | **SDDM** (synthwave theme) | Hyprland + Waybar, Walker, Mako, hyprpaper |
| **COSMIC** | `ghcr.io/neon798/hyprwave-cosmic:latest` | **cosmic-greeter** | Fedora COSMIC DE + Hyprwave theme/wallpaper |

Shared on both: **Neonwolf** (browser), **FlatArcade** (Flathub TUI), **Yazi** (file manager),
**Ghostty** (terminal), fonts, wallpapers, and the **`hyprwave-theme`** switcher.

For day-to-day desktop usage after install, see [docs/keybinds.md](docs/keybinds.md)
(Hyprland) and the [README](README.md) themes section.

---

## Requirements

### Switch an existing system (`bootc switch`)

You need a machine already running a **bootc-compatible** OS (for example Universal Blue /
Fedora Atomic images that provide `bootc`). You must be able to run privileged commands
(`sudo`) and reboot.

### Build ISO / qcow2 from source

- [Podman](https://podman.io/)
- [just](https://github.com/casey/just)
- For disk images (`build-iso`, `build-qcow2`, `run-vm-*`): **rootful Podman**, **sudo**, and ideally **KVM**

A plain container build does **not** need sudo:

```bash
just build hyprwave latest        # Hyprland variant
just build-cosmic                 # COSMIC variant → hyprwave-cosmic:latest
```

---

## Path 1 — Rebase with bootc (recommended if you already have bootc)

### Hyprland (default)

```bash
sudo bootc switch ghcr.io/neon798/hyprwave:latest
sudo systemctl reboot
```

### COSMIC

```bash
sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest
sudo systemctl reboot
```

### Switch between variants later

Same commands: `bootc switch` to the other image, then reboot. Your home directory is
preserved; desktop configs under `~/.config` are **not** rewritten (skel only applies to
**new** users — see [First login](#first-login)).

### After reboot

1. Confirm the deployment:
   ```bash
   bootc status
   ```
2. Log in at the greeter for your variant (SDDM or cosmic-greeter).
3. Optional: pull newer image layers without changing the image URL:
   ```bash
   sudo bootc upgrade
   sudo systemctl reboot
   ```

> **Note:** Public pull/sign status of `ghcr.io/neon798/*` may vary by registry
> permissions. If `bootc switch` or `podman pull` fails with auth errors, build locally
> (Path 2 / Path 3) or check the package visibility on GitHub Packages.

---

## Path 2 — Install from ISO

Build an Anaconda-style installer ISO that finishes with a `bootc switch` into the
published image (see `disk_config/iso.toml` and `disk_config/iso-cosmic.toml`).

### Hyprland ISO

```bash
just build hyprwave latest    # ensure localhost/hyprwave:latest exists (or set IMAGE_NAME)
just build-iso                # needs sudo / rootful Podman
```

### COSMIC ISO

```bash
just build-cosmic
just build-iso-cosmic
```

Artifacts land under the bootc-image-builder output directory (typically `output/` —
see the Justfile / BIB logs). Boot the ISO on real hardware or in a VM, complete the
installer (user, disk, network), and let the post-install kickstart switch to:

- Hyprland: `ghcr.io/neon798/hyprwave:latest`
- COSMIC: `ghcr.io/neon798/hyprwave-cosmic:latest`

The installed system still needs network access at install time (or a later
`bootc switch` / `bootc upgrade`) to pull the registry image if it is not already
cached.

---

## Path 3 — Local image + VM (developers)

Useful when iterating on the OS image without publishing to GHCR.

```bash
# Container image only
just build hyprwave latest
just build-cosmic

# Bootable qcow2 + browser-based QEMU (sudo + KVM)
just build-qcow2
just run-vm-qcow2

# COSMIC
just build-qcow2-cosmic
just run-vm-qcow2-cosmic

# Force a fresh container build then rebuild the disk
just rebuild-qcow2
```

Default local image name from the Justfile is `image-template` unless you set
`IMAGE_NAME=hyprwave` (CI sets the name to the repository name). Examples above use
`hyprwave` explicitly.

Fast **dotfile-only** rebuild (Hyprland skel + `/usr/share/hyprwave` assets) on top of
an existing image — does **not** reinstall packages:

```bash
podman build -f Dockerfile.overlay -t hyprwave:latest .
```

Remember: `/etc/skel` only applies to **newly created** users.

---

## First login

### Hyprland variant — SDDM

1. Boot completes into **SDDM** with the Hyprwave synthwave theme (deep purple panel,
   chromatic “HYPRWAVE” title, shared default wallpaper).
2. Select your user, enter password, start the session.
3. Hyprland starts with default skel (new users only), including:
   - **Waybar** (status bar)
   - **Walker** launcher (via elephant) — `Super+D` / `Super+Space`
   - **Mako** notifications
   - **hyprpaper** wallpaper
   - **hypridle** / lock stack
4. Default apps: **Ghostty** terminal, **Neonwolf** browser, **Yazi** (in Ghostty),
   **FlatArcade** for Flatpaks.
5. Themes: **Hyprwave Themes** app, or `Super+Shift+T`, or `hyprwave-theme set <name>`.

### COSMIC variant — cosmic-greeter

1. Boot completes into **cosmic-greeter** (not SDDM).
2. Log in to a **COSMIC** session.
3. Expect the Hyprwave vendor look: synthwave palette, default wallpaper, dock favorites
   including Neonwolf, Cosmic Files, Ghostty, FlatArcade, Cosmic Settings.
4. There is **no** Hyprland stack (no Walker / Waybar / Mako / hypr configs). Use COSMIC’s
   own launcher, panel, and notifications.
5. Themes still work via **Hyprwave Themes** / `hyprwave-theme` (applies COSMIC appearance
   keys + wallpaper + Ghostty).

### If the desktop looks “stock” after an upgrade

Skel is not re-copied for existing users. Either create a new user to pick up defaults,
or copy the pieces you want from `/etc/skel/` into your home directory carefully.

---

## Updates

Hyprwave is immutable at the base-image layer. Day-to-day:

```bash
# Base OS (new image layers for the current image ref)
sudo bootc upgrade
sudo systemctl reboot

# See current / staged deployments
bootc status

# Flatpak apps (user and/or system, depending how you install)
flatpak update
```

There is no traditional `dnf upgrade` of the whole OS. Layered packages (if you use
them) follow your host’s bootc / rpm-ostree workflow and still require a reboot when the
base deployment changes.

To move to a **different** image (e.g. Hyprland ↔ COSMIC):

```bash
sudo bootc switch ghcr.io/neon798/hyprwave:latest
# or
sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest
sudo systemctl reboot
```

---

## What you get (quick map)

| Role | Hyprland image | COSMIC image |
|------|----------------|--------------|
| Login | SDDM | cosmic-greeter |
| Shell / compositor | Hyprland | cosmic-comp / COSMIC session |
| Launcher | Walker (+ elephant plugins) | COSMIC launcher |
| Bar / panel | Waybar | COSMIC panel / dock |
| Wallpaper | hyprpaper | cosmic-bg (vendor wallpaper) |
| Notifications | Mako | COSMIC notifications |
| Terminal | Ghostty | Ghostty (promoted; cosmic-term remains for session) |
| Browser | Neonwolf | Neonwolf |
| Files | Yazi (keybind / desktop entry) | Cosmic Files + Yazi available |
| App store | FlatArcade | FlatArcade (cosmic-store removed) |
| Theme switcher | `hyprwave-theme` / GUI / Super+Shift+T | same CLI + GUI |

Eleven theme packs live under `/usr/share/hyprwave/themes/` (default **hyprwave** plus
ten others). See the [README](README.md#themes) for names and CLI usage.

---

## Troubleshooting

| Symptom | What to try |
|---------|-------------|
| `bootc switch` cannot pull image | Check network; try `podman pull ghcr.io/neon798/hyprwave:latest`; confirm package is public; build locally if private |
| Black screen after login (Hyprland) | Switch to a TTY, confirm `Hyprland` / GPU drivers; for NVIDIA, extra work may be required (not certified in-repo) |
| Walker shows no apps | Ensure `elephant` is running (`exec-once` in skel); restart: `systemctl --user restart app-walker@autostart.service` |
| Theme switch did nothing on old user | Point symlinks / run `hyprwave-theme set …` again; COSMIC may need a session restart for some keys |
| Want repo-dev docs | [CLAUDE.md](CLAUDE.md) / [AGENTS.md](AGENTS.md) for build architecture — not required for end users |

---

## See also

- [docs/keybinds.md](docs/keybinds.md) — Hyprland keyboard shortcuts
- [CHANGELOG.md](CHANGELOG.md) — what ships and what changed
- [README.md](README.md) — product overview, companions, themes, COSMIC notes
- [Justfile](Justfile) — all `just` recipes (`just --list`)
