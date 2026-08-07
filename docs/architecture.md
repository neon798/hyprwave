# Architecture (user-facing)

Short map of how Hyprwave is put together. You do not need this to *use* the system;
it explains why install, updates, and configs behave the way they do.

---

## Bootable container (bootc)

Hyprwave is not a classic “install RPMs forever” distro. The OS is a **bootable container
image** (bootc) derived from Universal Blue’s Fedora Atomic base
(`ghcr.io/ublue-os/base-main`).

| Concept | What it means for you |
|---------|------------------------|
| Immutable base | System files under `/usr` come from the image. Day-to-day “upgrade the OS” = pull a new image deployment. |
| `bootc switch` | Change which image ref you boot (e.g. stock Atomic → Hyprwave, or Hyprland → COSMIC). |
| `bootc upgrade` | Stay on the same ref; pull newer layers when the registry publishes them. |
| Reboot required | New base deployments activate after reboot. |
| Home is yours | `/home` is not rewritten by image switches. |

There is no full-OS `dnf upgrade` of the desktop image the way a mutable Fedora Workstation
works. Flatpaks and user data update separately — see [updating.md](updating.md).

---

## Two image variants

Build-time argument `DE` selects the desktop:

| | Hyprland (`hyprwave`) | COSMIC (`hyprwave-cosmic`) |
|--|----------------------|---------------------------|
| Image | `ghcr.io/neon798/hyprwave:latest` | `ghcr.io/neon798/hyprwave-cosmic:latest` |
| Greeter | SDDM (synthwave theme) | cosmic-greeter |
| Session | Hyprland + Waybar, Walker, Mako, hyprpaper | Fedora COSMIC DE |
| Hypr stack | Yes | No |
| Shared apps | Neonwolf, FlatArcade, Yazi, Ghostty, themes CLI | Same companions + COSMIC apps |

Same repo, one `Containerfile`, matrix CI. Details for COSMIC users: [cosmic.md](cosmic.md).

---

## Layers of the image

```
┌─────────────────────────────────────────────┐
│  Your home (~/.config, Flatpaks, files)     │  mutable, per-user
├─────────────────────────────────────────────┤
│  /etc (including skel → only for new users) │  local config
├─────────────────────────────────────────────┤
│  /usr  (packages, themes, greeter, apps)    │  from bootc image
├─────────────────────────────────────────────┤
│  Universal Blue / Fedora Atomic base        │  bootc base
└─────────────────────────────────────────────┘
```

### Theme store

System theme packs live under:

```text
/usr/share/hyprwave/themes/<name>/
```

Eleven packs ship (default **hyprwave** + ten others). The switcher
(`hyprwave-theme` / GUI) points `~/.config/hyprwave/theme` at a pack and reloads the
active desktop (Hyprland live-reload vs COSMIC appearance keys).

### Default user configs (`/etc/skel`)

Files under `/etc/skel/` are copied **only when a user account is created**.

| Implication | Action |
|-------------|--------|
| You upgraded the image | Your existing `~/.config` is **not** overwritten |
| You want new defaults | New user, or carefully copy from `/etc/skel/` |
| You broke Hyprland config | Diff against `/etc/skel/.config/hypr/` |

This is the most common source of “the README says X but my machine does Y” after upgrades.

---

## Desktop stack (Hyprland image)

| Role | Component |
|------|-----------|
| Compositor | Hyprland |
| Launcher | Walker + elephant plugins |
| Bar | Waybar |
| Notifications | Mako |
| Wallpaper | hyprpaper |
| Idle / lock | hypridle, hyprlock |
| Login | SDDM + Hyprwave QML theme |

Some Hyprland utilities are **source-built** in a multi-stage container build
(hyprpaper, hyprpicker, hyprsunset, hyprland-qtutils) so the final image stays free of
the heavy `-devel` toolchain.

---

## Companion apps

| App | Role | Notes |
|-----|------|--------|
| Neonwolf | Browser | AppImage extracted at **image build** time → `/usr/lib/neonwolf/` |
| FlatArcade | Flatpak “store” TUI | Flathub-oriented |
| Yazi | File manager | Terminal UI; often launched inside Ghostty |
| Ghostty | Terminal | Default on both variants |

These are part of the OS image, not something you download after first boot (unless you
rebuild from source).

---

## What this repo is

Hyprwave’s git repository is a customized Universal Blue **image-template**:

- `Containerfile` — base image + build stages  
- `build_files/build.sh` — packages, services, skel deploy  
- `build_files/etc/skel/` — default dotfiles  
- `Justfile` — `just build`, ISO, VM helpers  

There is no separate “application monorepo” for the desktop itself. Contributor-oriented
detail lives in `CLAUDE.md` / `AGENTS.md` (optional for end users).

---

## Planned but not stock (do not assume installed)

Other lanes may ship **dormant** packages later:

- **Hyprwave Assistant** — TUI for updates / Flatpak / docs (not claimed as default on `main` until merged and hooked)
- **Duress password** — optional PAM tooling, **off by default** even after packaging lands

See [security.md](security.md) and [CHANGELOG.md](../CHANGELOG.md).

---

## See also

- [INSTALL.md](../INSTALL.md) — switch / ISO / first login  
- [updating.md](updating.md) — upgrades  
- [troubleshooting.md](troubleshooting.md) — when things break  
- [keybinds.md](keybinds.md) — Hyprland shortcuts  
