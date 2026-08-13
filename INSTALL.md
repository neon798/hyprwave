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

Docs index: [docs/README.md](docs/README.md) ·
[First boot](docs/first-boot.md) ·
[Keybinds](docs/keybinds.md) ·
[COSMIC](docs/cosmic.md) ·
[Updates](docs/updating.md)

---

## Choose a variant (Hyprland vs COSMIC)

Pick **one** image first. You can switch later with `bootc switch` (home kept; desktop
configs are not auto-migrated).

```text
Want a tiling, keyboard-first Wayland session (Walker, Waybar, Super+binds)?
    └─► Hyprland image  —  ghcr.io/neon798/hyprwave:latest
        Greeter: SDDM · Guide: docs/keybinds.md · docs/first-boot.md

Want a full desktop environment (panel, dock, Settings app)?
    └─► COSMIC image  —  ghcr.io/neon798/hyprwave-cosmic:latest
        Greeter: cosmic-greeter · Guide: docs/cosmic.md · docs/first-boot.md

Both share: Neonwolf, FlatArcade, Yazi, Ghostty, 11-theme switcher (hyprwave-theme)
```

| Decision | Hyprland | COSMIC |
|----------|----------|--------|
| Greeter | SDDM (synthwave theme) | cosmic-greeter (upstream face; session is branded) |
| Launcher / bar | Walker + Waybar | COSMIC launcher + panel/dock |
| Default Super+binds | Yes ([keybinds.md](docs/keybinds.md)) | No — COSMIC settings |
| Local build | `just build hyprwave latest` / `just build-iso` (default `IMAGE_NAME=image-template`) | `just build-cosmic` / `just build-iso-cosmic` |

More comparison: [docs/cosmic.md](docs/cosmic.md). After install: [docs/first-boot.md](docs/first-boot.md).

---

<a id="important-ghcr-is-private-anonymous-pull-fails"></a>

## Important: GHCR is private (anonymous pull fails)

Published refs are intended to live on GitHub Container Registry:

```text
ghcr.io/neon798/hyprwave:latest
ghcr.io/neon798/hyprwave-cosmic:latest
```

**Today, anonymous access still returns 401/403.** Do **not** treat
`podman pull ghcr.io/neon798/hyprwave:latest` or bare `bootc switch` to those
refs as a public install path. That is a registry visibility / auth setting, not a
broken command.

| Situation | What to do |
|-----------|------------|
| You **clone this repo** and can run Podman | **Primary path:** local build → Path **C** (VM) or Path **B** (ISO). Tags: `localhost/hyprwave:latest` when you pass `IMAGE_NAME=hyprwave` / `just build hyprwave latest` |
| You have **GHCR credentials** (collaborator / PAT) | `podman login ghcr.io`, then Path **A** if desired |
| You only have the public internet, no clone | Wait for public packages, or get a mirror the maintainer publishes |

Optional diagnostic (expect **403** while packages stay private):

```bash
# Does NOT mean GHCR is public — use this only to confirm access
podman pull ghcr.io/neon798/hyprwave:latest
# 403/unauthorized → use Path C or B; do not keep retrying anonymous pull
```

Details: [docs/troubleshooting.md](docs/troubleshooting.md#install--registry).

---

## Choose an install path (local build first)

After you know **which variant** you want, pick how you will **obtain the image**.
While GHCR is private, **build from this repository** is the reliable default.

```text
Can you clone this repo and run Podman/just?
    ├─ Yes — try the desktop in a VM ──► Path C: just build + qcow2  (no GHCR)
    ├─ Yes — need installer media     ──► Path B: just build-iso     (retarget if kickstart needs GHCR)
    └─ No, but you have GHCR auth     ──► Path A: bootc switch       (after podman login)
Already on Atomic and GHCR is public later ──► Path A becomes the short path
```

| Path | When | Needs public GHCR? |
|------|------|--------------------|
| **C — local build + VM** | **Primary today** — anyone with the git repo | **No** — `localhost/hyprwave:latest` (and cosmic) |
| **B — ISO** | Clean install media from a local build | Kickstart may still pull GHCR unless you retarget |
| **A — `bootc switch`** | Existing Atomic host **and** registry access | Yes (public) **or** `podman login` / your mirror |

Registry status: [section above](#important-ghcr-is-private-anonymous-pull-fails).

---

## Path A — Rebase an existing Atomic host (`bootc switch`)

**Requirements:** a bootc-capable OS, `sudo`, network, ability to reboot, and
**registry access** (public GHCR **or** `podman login ghcr.io` with a token that can
read the package). If anonymous pull is 403, use **Path C** or **B** instead of
retrying Path A.

**Requirements (summary):** bootc host + authenticated or public image pull.

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
[docs/first-boot.md](docs/first-boot.md) and [Post-install](#post-install-first-hour).

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

<a id="path-c-local"></a>

## Path C — Local image + VM (**recommended while GHCR is private**)

Build `localhost/hyprwave:latest` (and cosmic) from this tree — no anonymous GHCR.

```bash
just build hyprwave latest
just build-cosmic

just build-qcow2 && just run-vm-qcow2
just build-qcow2-cosmic && just run-vm-qcow2-cosmic
just rebuild-qcow2          # force fresh container build, then disk
```

#### Local image name (`IMAGE_NAME`)

The Justfile default is **`IMAGE_NAME=image-template`** (Universal Blue template
name), **not** `hyprwave`:

```bash
# Plain `just build` tags: localhost/image-template:latest
just build

# Tag as hyprwave (what most docs and overlay examples expect):
just build hyprwave latest
# equivalent:
IMAGE_NAME=hyprwave just build

# COSMIC recipes use the same IMAGE_NAME pattern with a -cosmic suffix in recipes
just build-cosmic
```

**CI** sets the image name from the **repository name** (`hyprwave`). Local clones
must pass `hyprwave` (or export `IMAGE_NAME`) if you want tags that match INSTALL
examples, `Dockerfile.overlay` (`hyprwave:latest`), and Path A/B GHCR names.
**Do not edit the Justfile** just to rename the default — override at invoke time.

Dotfile-only overlay (no full package rebuild):

```bash
podman build -f Dockerfile.overlay -t hyprwave:latest .
```

---

## First login

Step-by-step narrative (login → bar/launcher → apps → themes → updates):
**[docs/first-boot.md](docs/first-boot.md)**.

### Hyprland — SDDM

1. Boot into **SDDM** (synthwave theme: purple panel, “HYPRWAVE” title).
2. Log in → **Hyprland** session with skel defaults (**new users only**):
   - Waybar, Walker (elephant), Mako, hyprpaper, hypridle
3. Try: **Super+D** (Walker), **Super+Return** (Ghostty), **Super+B** (Neonwolf).
   Exit session: **Super+Shift+E** — see [keybinds.md](docs/keybinds.md).

### COSMIC — cosmic-greeter

1. Boot into **cosmic-greeter** (not SDDM). Greeter face may be upstream stock;
   session wallpaper/theme is Hyprwave-branded. Greeter limits:
   [GREETER.md](planning/integration/f-cosmic/GREETER.md).
2. COSMIC session with dock favorites (Neonwolf, FlatArcade, Ghostty, Files,
   Hyprwave Themes, Settings — order per F vendor inventory).
3. No Walker/Waybar — use COSMIC’s launcher. Themes still via **Hyprwave Themes**.

More: [docs/cosmic.md](docs/cosmic.md).

### Skel caveat

`/etc/skel` copies into a home **only when the user is created**. Image upgrades do not
reset `~/.config`. Details: [docs/architecture.md](docs/architecture.md).

---

## Post-install (first hour)

Follow [docs/first-boot.md](docs/first-boot.md) for the full path. Short list:

1. **Confirm image:** `bootc status`
2. **Browser:** launch **Neonwolf** (Hyprland: Super+B)
3. **Apps:** open **FlatArcade** (Hyprland: Super+A) and install Flatpaks from Flathub
4. **Files:** **Yazi** (Hyprland: Super+E in Ghostty); COSMIC also has Cosmic Files
5. **Themes:** **Hyprwave Themes** app, or Hyprland **Super+Shift+T**, or:
   ```bash
   hyprwave-theme list
   hyprwave-theme set vaporwave
   ```
   Eleven packs under `/usr/share/hyprwave/themes/` — full guide:
   [docs/theming.md](docs/theming.md).
6. **Terminal:** Ghostty (Super+Return / Super+T on Hyprland)
7. **FAQ / help:** [docs/faq.md](docs/faq.md) · [docs/troubleshooting.md](docs/troubleshooting.md)
8. **Updates later:** [docs/updating.md](docs/updating.md)

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
| 403 on pull / switch | [GHCR section](#important-ghcr-is-private-anonymous-pull-fails), [troubleshooting](docs/troubleshooting.md#install--registry) |
| Black screen (Hyprland) | [troubleshooting — black screen](docs/troubleshooting.md#black-screen-after-sddm-login) |
| No wallpaper | [troubleshooting — wallpaper](docs/troubleshooting.md#no-wallpaper) |
| Walker empty | [troubleshooting — Walker](docs/troubleshooting.md#walker-empty--no-apps--does-nothing) |
| NVIDIA | Not certified in-repo; see troubleshooting GPU notes |

Full index: [docs/troubleshooting.md](docs/troubleshooting.md).

---

## See also

- [docs/README.md](docs/README.md) — handbook index  
- [docs/first-boot.md](docs/first-boot.md) — login through first-hour tour  
- [docs/faq.md](docs/faq.md) — common questions  
- [docs/keybinds.md](docs/keybinds.md) — Hyprland shortcuts (E-lane map)  
- [docs/theming.md](docs/theming.md) — theme packs  
- [docs/security.md](docs/security.md) — immutability, duress off by default  
- [CHANGELOG.md](CHANGELOG.md) · [README.md](README.md) · `just --list`
