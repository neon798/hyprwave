# Install Hyprwave

Hyprwave is a **bootc** (bootable container) image: an immutable Fedora Atomic–based OS.
You install by **rebasing** an existing Atomic/bootc host, or by building an **ISO**
from this repository.

| Variant | Image | Greeter | Desktop |
|---------|-------|---------|---------|
| **Hyprland** (default) | `ghcr.io/neon798/hyprwave:latest` | **SDDM** | Hyprland + Waybar, Walker, Mako, hyprpaper |
| **COSMIC** | `ghcr.io/neon798/hyprwave-cosmic:latest` | **cosmic-greeter** | Fedora COSMIC + Hyprwave theme |

**Both variants include:** Neonwolf (browser), FlatArcade (Flathub TUI), Yazi, Ghostty,
fonts, wallpapers, and **`hyprwave-theme`**.

Docs index: [docs/README.md](docs/README.md) · Keybinds: [docs/keybinds.md](docs/keybinds.md) ·
COSMIC: [docs/cosmic.md](docs/cosmic.md) · Updates: [docs/updating.md](docs/updating.md)

---

## Important: GHCR may be private

Published refs use GitHub Container Registry:

```text
ghcr.io/neon798/hyprwave:latest
ghcr.io/neon798/hyprwave-cosmic:latest
```

**Until package visibility is set to public**, anonymous `bootc switch` / `podman pull`
can fail with **401/403**. That is an ops/registry setting, not a missing install command.

| If pull works | If pull fails (private/403) |
|---------------|----------------------------|
| Use **Path A** (`bootc switch`) below | Use **Path B** (build ISO/image from this repo) or wait for public GHCR |
| Then `bootc upgrade` for later updates | After a local/private publish, authenticate or retarget your own registry |

Test without switching:

```bash
podman pull ghcr.io/neon798/hyprwave:latest
```

Details: [docs/troubleshooting.md](docs/troubleshooting.md#install--registry).

---

## Choose an install path

```text
Already on Fedora Atomic / Universal Blue / any bootc host?
    ├─ Yes, and GHCR pull works ──► Path A: bootc switch (fastest)
    ├─ Yes, but GHCR is private ──► Path B (local build) or fix registry access
    └─ No / bare metal / VM from installer media ──► Path B: ISO
Developer iterating on the image ──► Path C: local container + qcow2 VM
```

---

## Path A — Rebase an existing Atomic host (`bootc switch`)

**Requirements:** a bootc-capable OS, `sudo`, network, ability to reboot.

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

### Switch variants later

Same `bootc switch` to the other image, then reboot. `/home` is kept; **desktop configs
are not rewritten** (see [skel caveat](#skel-caveat)).

### After reboot

```bash
bootc status    # confirm booted image
```

Log in at **SDDM** (Hyprland) or **cosmic-greeter** (COSMIC), then follow
[Post-install](#post-install-first-hour).

Day-to-day upgrades (same image ref): see [docs/updating.md](docs/updating.md) —
`sudo bootc upgrade` then reboot.

---

## Path B — Install from ISO

Build an Anaconda-style installer that finishes with a kickstart `bootc switch` into
the published image (`disk_config/iso.toml` / `iso-cosmic.toml`).

**Requirements:** [Podman](https://podman.io/), [just](https://github.com/casey/just),
**sudo** / rootful Podman (and ideally KVM for testing).

### Hyprland ISO

```bash
just build hyprwave latest
just build-iso
```

### COSMIC ISO

```bash
just build-cosmic
just build-iso-cosmic
```

Boot the ISO from `output/` (or the path bootc-image-builder prints). Complete user,
disk, and network steps. Post-install kickstart targets:

- Hyprland → `ghcr.io/neon798/hyprwave:latest`
- COSMIC → `ghcr.io/neon798/hyprwave-cosmic:latest`

The installer host still needs registry access for that switch unless you customize BIB
config for a local mirror. If GHCR is private, fix visibility or point kickstart at an
image you control before relying on Path B for end users.

---

## Path C — Developers (local image + VM)

```bash
just build hyprwave latest
just build-cosmic

just build-qcow2 && just run-vm-qcow2
just build-qcow2-cosmic && just run-vm-qcow2-cosmic
just rebuild-qcow2          # force fresh container build, then disk
```

Default Justfile `IMAGE_NAME` is `image-template` unless you set `IMAGE_NAME=hyprwave`
(CI uses the repo name). Examples above pass `hyprwave` explicitly.

Dotfile-only overlay (no full package rebuild):

```bash
podman build -f Dockerfile.overlay -t hyprwave:latest .
```

---

## First login

### Hyprland — SDDM

1. Boot into **SDDM** (synthwave theme: purple panel, “HYPRWAVE” title).
2. Log in → **Hyprland** session with skel defaults (**new users only**):
   - Waybar, Walker (elephant), Mako, hyprpaper, hypridle
3. Try: **Super+D** (Walker), **Super+Return** (Ghostty), **Super+B** (Neonwolf).

### COSMIC — cosmic-greeter

1. Boot into **cosmic-greeter** (not SDDM).
2. COSMIC session with Hyprwave wallpaper/palette and dock favorites
   (Neonwolf, Files, Ghostty, FlatArcade, Settings).
3. No Walker/Waybar — use COSMIC’s launcher. Themes still via **Hyprwave Themes**.

More: [docs/cosmic.md](docs/cosmic.md).

### Skel caveat

`/etc/skel` copies into a home **only when the user is created**. Image upgrades do not
reset `~/.config`. Details: [docs/architecture.md](docs/architecture.md).

---

## Post-install (first hour)

1. **Confirm image:** `bootc status`
2. **Browser:** launch **Neonwolf** (Hyprland: Super+B)
3. **Apps:** open **FlatArcade** (Hyprland: Super+A) and install Flatpaks from Flathub
4. **Files:** **Yazi** (Hyprland: Super+E in Ghostty); COSMIC also has Cosmic Files
5. **Themes:** **Hyprwave Themes** app, or Hyprland **Super+Shift+T**, or:
   ```bash
   hyprwave-theme list
   hyprwave-theme set vaporwave
   ```
   Eleven packs under `/usr/share/hyprwave/themes/`.
6. **Terminal:** Ghostty (Super+Return / Super+T on Hyprland)
7. **Updates later:** [docs/updating.md](docs/updating.md)

| Role | Hyprland | COSMIC |
|------|----------|--------|
| Login | SDDM | cosmic-greeter |
| Launcher | Walker | COSMIC launcher |
| Bar | Waybar | COSMIC panel/dock |
| Wallpaper | hyprpaper | cosmic-bg |
| Notifications | Mako | COSMIC |
| Theme switcher | `hyprwave-theme` + Super+Shift+T | CLI + GUI |

---

## Updates (summary)

```bash
sudo bootc upgrade
sudo systemctl reboot
flatpak update          # apps
```

Full guide: [docs/updating.md](docs/updating.md).

---

## Troubleshooting

| Symptom | Start here |
|---------|------------|
| 403 on pull / switch | [GHCR section](#important-ghcr-may-be-private), [troubleshooting](docs/troubleshooting.md#install--registry) |
| Black screen (Hyprland) | [troubleshooting — black screen](docs/troubleshooting.md#black-screen-after-sddm-login) |
| No wallpaper | [troubleshooting — wallpaper](docs/troubleshooting.md#no-wallpaper) |
| Walker empty | [troubleshooting — Walker](docs/troubleshooting.md#walker-empty--no-apps--does-nothing) |
| NVIDIA | Not certified in-repo; see troubleshooting GPU notes |

Full index: [docs/troubleshooting.md](docs/troubleshooting.md).

---

## See also

- [docs/README.md](docs/README.md) — all end-user docs  
- [docs/keybinds.md](docs/keybinds.md) — Hyprland shortcuts  
- [docs/security.md](docs/security.md) — immutability, duress off by default  
- [CHANGELOG.md](CHANGELOG.md) · [README.md](README.md) · `just --list`
