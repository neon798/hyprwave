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

Install paths (rebase vs ISO vs local build): [INSTALL.md](../INSTALL.md).

---

## Two image variants (dual DE)

Build-time argument `DE` selects the desktop at **image build** time (not a session
toggle on one disk):

| | Hyprland (`hyprwave`) | COSMIC (`hyprwave-cosmic`) |
|--|----------------------|---------------------------|
| Image | `ghcr.io/neon798/hyprwave:latest` | `ghcr.io/neon798/hyprwave-cosmic:latest` |
| Greeter | SDDM (synthwave theme) | cosmic-greeter |
| Session | Hyprland + Waybar, Walker, Mako, hyprpaper | Fedora COSMIC DE |
| Hypr stack | Yes | No |
| Shared apps | Neonwolf, FlatArcade, Yazi, Ghostty, `hyprwave-theme` | Same companions + COSMIC shell apps |

Same repo, one `Containerfile` (stage alias `de-${DE}`), matrix CI. COSMIC details:
[cosmic.md](cosmic.md). First hour: [first-boot.md](first-boot.md).

Switching variants later is another `bootc switch` + reboot; desktop configs do not
auto-migrate.

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
active desktop (Hyprland live-reload vs COSMIC appearance keys under `~/.config/cosmic/`).

| Layer | Path | Notes |
|-------|------|--------|
| Pack store | `/usr/share/hyprwave/themes/<name>/` | Immutable with the image |
| Active pointer | `~/.config/hyprwave/theme` | Per-user; new users get skel defaults |
| COSMIC vendor defaults | `/usr/share/cosmic/` | First-boot dock/wallpaper/theme on COSMIC image |

Guide: [theming.md](theming.md).

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

Keybinds: [keybinds.md](keybinds.md) (E-lane ENDPOINT may still be pending merge —
handbook notes that).

---

## Companion apps

| App | Role | Notes |
|-----|------|--------|
| Neonwolf | Browser | AppImage extracted at **image build** time → `/usr/lib/neonwolf/` |
| FlatArcade | Flatpak “store” TUI | Flathub-oriented |
| Yazi | File manager | Terminal UI; often launched inside Ghostty |
| Ghostty | Terminal | Default on both variants |

These are part of the OS image, not something you download after first boot (unless you
rebuild from source). Companion **version pins** may still land from `lane/a-stabilize`
— not assumed on published `:latest` until merge ([CHANGELOG.md](../CHANGELOG.md)).

---

## Optional / lane packaging boundaries (not stock UX)

Wave-1 parallel work may ship **additional packages or assets** without changing the
default login story. Treat these as **boundaries**, not features you must use.

### Hyprwave Assistant (lane C — pending merge / image hook)

| | |
|--|--|
| Intent | Go TUI for updates / Flatpak / offline knowledge base |
| Stock claim | **Do not** assume `/usr/bin/hyprwave-assistant` on disk until CHANGELOG lists it as image-hooked |
| Boundary | Convenience UI only — confirm OS upgrades; reboot still required after `bootc upgrade` |
| Docs | Mentioned in [security.md](security.md) / FAQ as upcoming; not an INSTALL step |

### Duress packaging (lane D — pending merge; **off by default**)

| | |
|--|--|
| Intent | Optional [pam-duress](https://github.com/nuvious/pam-duress) **assets** (module, templates, setup CLI) |
| Stock claim | **PAM never enabled by default**; packaging alone changes nothing at login |
| Boundary | Admin ENABLE docs only; not LUKS; not forensic wipe; no handbook enable paste |
| Docs | [security.md](security.md) — residual risks and non-goals |

### QA / merge tooling (lane G)

Scripts and smoke matrices live under `planning/` / integration trees for contributors.
They are **not** end-user desktop features.

Honesty table for all lanes: [CHANGELOG.md](../CHANGELOG.md) Unreleased.

---

## What this repo is

Hyprwave’s git repository is a customized Universal Blue **image-template**:

- `Containerfile` — base image + build stages  
- `build_files/build.sh` — packages, services, skel deploy  
- `build_files/etc/skel/` — default dotfiles  
- `Justfile` — `just build`, ISO, VM helpers  

There is no separate “application monorepo” for the desktop itself. Contributor-oriented
detail lives in `CLAUDE.md` / `AGENTS.md` and
[contributor-notes.md](contributor-notes.md).

---

## See also

- [INSTALL.md](../INSTALL.md) — switch / ISO / first login  
- [first-boot.md](first-boot.md) — healthy first session  
- [updating.md](updating.md) — upgrades  
- [troubleshooting.md](troubleshooting.md) — dual-variant matrix  
- [keybinds.md](keybinds.md) — Hyprland shortcuts  
- [security.md](security.md) — immutability + optional duress  
