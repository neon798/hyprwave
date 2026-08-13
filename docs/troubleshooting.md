# Troubleshooting

Quick fixes for common Hyprwave issues. For install steps see [INSTALL.md](../INSTALL.md).
For first-hour expectations see [first-boot.md](first-boot.md). Structure:
[architecture.md](architecture.md).

---

## Dual-variant matrix (start here)

| Symptom area | **Hyprland** image | **COSMIC** image |
|--------------|--------------------|------------------|
| Greeter / DM | **SDDM** (`sddm.service`); synthwave theme | **cosmic-greeter** (`cosmic-greeter.service`); upstream face OK |
| `display-manager.service` | → SDDM | → cosmic-greeter |
| Session chrome | Waybar, hyprpaper, mako, hypridle | COSMIC panel/dock, cosmic-bg |
| App launcher | **Walker** + **elephant** (Super+D / Super+Space) | **COSMIC launcher** (no Walker) |
| Notifications | **Mako** | COSMIC notifications |
| Theme switcher | `hyprwave-theme` / GUI / **Super+Shift+T** | Same CLI/GUI; dock may pin **Hyprwave Themes** |
| Wallpaper | hyprpaper + theme pack wallpapers | vendor CosmicBackground + `hyprwave-theme` |
| Lock | **hyprlock** (Super+Shift+L) | COSMIC lock / greeter path |
| Default terminal | Ghostty (Super+Return / Super+T) | Ghostty (dock / launcher) |
| Browser / store | Super+B Neonwolf · Super+A FlatArcade | Dock Neonwolf · FlatArcade |
| Files | Super+E → Yazi in Ghostty | Cosmic Files + optional Yazi |
| Keybind map | [keybinds.md](keybinds.md) | COSMIC Settings only — Super binds N/A |
| Variant guide | — | [cosmic.md](cosmic.md) |

Confirm which image you booted:

```bash
bootc status
systemctl status display-manager.service --no-pager
```

---

## Install / registry

### `bootc switch` or `podman pull` fails (401 / 403 / unauthorized)

**Likely cause:** the GHCR package is **private** or you are not logged in.

1. Try an anonymous pull:
   ```bash
   podman pull ghcr.io/neon798/hyprwave:latest
   # or
   podman pull ghcr.io/neon798/hyprwave-cosmic:latest
   ```
2. If you get **403** / unauthorized without a token, the package is probably not public yet.
   Hyprwave may remain private until the maintainer sets GitHub Packages visibility.
3. Workarounds:
   - Build locally: `just build hyprwave latest` then use a local/ostree transport your host supports
   - Build an ISO from this repo and install offline-capable paths (still needs registry for kickstart
     switch unless you retarget BIB config)
   - Authenticate only if you have access: `podman login ghcr.io`

See also [INSTALL.md](../INSTALL.md) — dual install paths and the private-image note.

### `bootc switch` fails with network / TLS errors

- Confirm DNS and outbound HTTPS from the host.
- Retry later (transient registry or mirror issues).
- Check disk space: `df -h /` and bootc needs room for a new deployment.

### Wrong image after reboot

```bash
bootc status
```

Confirm the **booted** image ref matches what you switched to
(`…/hyprwave:latest` vs `…/hyprwave-cosmic:latest`). If a previous deployment is still
default, use your host’s rollback / pin tools (`bootc` / `rpm-ostree` docs for your base).

---

## First login / greeter

### No greeter / stuck at text console

| Variant | Expected greeter | Status unit |
|---------|------------------|-------------|
| Hyprland image | **SDDM** | `sddm.service` |
| COSMIC image | **cosmic-greeter** | `cosmic-greeter.service` |

On a TTY:

```bash
systemctl status display-manager.service
readlink -f /etc/systemd/system/display-manager.service
systemctl status sddm.service            # Hyprland image only
systemctl status cosmic-greeter.service  # COSMIC image only
journalctl -b -u display-manager.service --no-pager | tail -80
```

| If… | Check |
|-----|--------|
| Hyprland image shows cosmic-greeter | Wrong image ref or partial layer — `bootc status` |
| COSMIC image shows SDDM | Wrong image — switch to `hyprwave-cosmic` |
| Unit failed | journal + GPU / seat issues |

COSMIC greeter may use **upstream** styling; session wallpaper is still Hyprwave-branded.
Operator notes: [GREETER.md](../planning/integration/f-cosmic/GREETER.md).

### Cannot log in (password rejected)

- Caps Lock / wrong keyboard layout at greeter.
- On a multi-user install, confirm the username Anaconda created.
- Recovery: boot older deployment if available, or use a live environment — do not confuse
  with optional **duress** tooling (that is **off by default** and not part of stock auth;
  see [security.md](security.md)).

---

## Hyprland session

### Black screen after SDDM login

1. Switch to a TTY (`Ctrl+Alt+F3`), log in.
2. Check whether Hyprland is running / crashed:
   ```bash
   journalctl --user -b --no-pager | tail -100
   ls -la ~/.config/hypr/
   ```
3. Try starting manually (from TTY with a working Wayland/X setup this may fail; prefer logs):
   ```bash
   Hyprland
   ```
4. **GPU / NVIDIA:** Hyprwave is not hardware-certified for proprietary NVIDIA stacks in this
   repo. Prefer open drivers where possible; for NVIDIA you may need host-level driver work
   outside the default image (out of scope for stock docs).
5. Broken user config: compare with `/etc/skel/.config/hypr/` (skel only auto-applies to
   **new** users).

### No wallpaper

Hyprland uses **hyprpaper**, not swaybg.

```bash
pgrep -a hyprpaper
hyprctl hyprpaper wallpaper 2>/dev/null || true
# theme / path
ls -la ~/.config/hyprwave/theme
ls /usr/share/hyprwave/themes/*/wallpapers/ 2>/dev/null | head
hyprwave-theme current
hyprwave-theme set hyprwave
```

Autostart should launch hyprpaper (`~/.config/hypr/autostart.conf`). Reload:

```bash
hyprctl reload
```

### Waybar missing

```bash
pgrep -a waybar
waybar &
# or re-login
```

### Walker empty / no apps / does nothing

Walker 2.x needs the **elephant** daemon and plugins. **Not used on COSMIC** — use the
COSMIC launcher there.

```bash
pgrep -a elephant
pgrep -a walker
systemctl --user restart app-walker@autostart.service
# if the unit name differs on your session:
systemctl --user list-units '*walker*' '*elephant*'
# raw Hyprland sessions also exec-once elephant + walker service (autostart.conf)
```

Also:

- Icon themes: after adding icons on a custom image, `gtk-update-icon-cache` may be needed
  (image builds already refresh hicolor when packaging).
- Open Walker with **Super+D** or **Super+Space** (see [keybinds.md](keybinds.md)).
- Runner mode: **Super+R** (`walker --prefix ">"`).

### Themes GUI / CLI does nothing (Hyprland)

```bash
hyprwave-theme list
hyprwave-theme set vaporwave
hyprwave-theme-gui          # or Super+Shift+T
```

- Should live-reload bar/launcher/borders; open a **new** Ghostty window for terminal colors.
- Existing users without skel symlinks: ensure `~/.config/hyprwave/theme` points at a pack under
  `/usr/share/hyprwave/themes/`.

### Keybinds not working

Defaults live in `~/.config/hypr/bindings.conf`. If you overwrote skel early, restore from
`/etc/skel/.config/hypr/bindings.conf`. Super = Windows key. Session
exit is **Super+Shift+E** (not Super+M on new-user skel) — [keybinds.md](keybinds.md).

---

## COSMIC session

Full comparison: [cosmic.md](cosmic.md). Session smoke:
[SESSION-SMOKE.md](../planning/integration/f-cosmic/SESSION-SMOKE.md).

### Session never appears / loops to greeter

```bash
journalctl -b --no-pager | tail -120
loginctl
systemctl --user status 2>/dev/null | head
```

Confirm image is **hyprwave-cosmic**, not the Hyprland image with a manual COSMIC install.

### Dock / favorites wrong or empty

Fresh vendor defaults pin (order on F lane): Neonwolf → FlatArcade → Ghostty → Cosmic
Files → Hyprwave Themes → Cosmic Settings. User overrides live under `~/.config/cosmic/`.

```bash
ls /usr/share/cosmic/com.system76.CosmicAppList/v1/favorites 2>/dev/null
```

### No Hyprwave wallpaper on COSMIC

```bash
ls -l /usr/share/backgrounds/hyprwave/default.png
hyprwave-theme current
hyprwave-theme set hyprwave
```

Greeter background may still look stock — that is a **known limit**; check **after login**.

### “Walker / Waybar / Super+D” does nothing

**Expected on COSMIC.** Those are Hyprland-only. Use COSMIC launcher and dock.

### Themes GUI / CLI (COSMIC)

```bash
hyprwave-theme list
hyprwave-theme set fjord-dark
hyprwave-theme-gui
```

Appearance keys write under `~/.config/cosmic/`; wait a moment or re-login if chrome
does not update. Same 11 packs as Hyprland — [theming.md](theming.md).

### cosmic-store still showing

Stock declutter removes **cosmic-store** in favor of FlatArcade. If you see it, you may
be on a non-Hyprwave COSMIC layer or a custom image. Prefer FlatArcade for Flathub.

---

## Theme switcher (both variants)

| Check | Command / action |
|-------|------------------|
| List packs | `hyprwave-theme list` (expect 11) |
| Current | `hyprwave-theme current` |
| Apply | `hyprwave-theme set <name>` |
| GUI | `hyprwave-theme-gui` or Hyprland **Super+Shift+T** |
| Store path | `/usr/share/hyprwave/themes/` |

If CLI is missing, the image may predate the theme switcher or the package set is incomplete
— re-switch/rebuild the image.

---

## Apps (both variants)

### Neonwolf will not start

```bash
neonwolf --version 2>/dev/null || true
ls /usr/lib/neonwolf/AppRun
/usr/bin/neonwolf
```

If the launcher is missing, the image build may be incomplete — reinstall/switch image.

### FlatArcade / Flatpak issues

```bash
flatpak remotes
flatpak update
flatarcade
```

Flathub should already be configured on the Universal Blue–style base. Network required for installs.

### Yazi

```bash
yazi
# Hyprland default: Super+E → Ghostty -e yazi
```

---

## Updates

Problems applying upgrades? See [updating.md](updating.md).

```bash
bootc status
sudo bootc upgrade
# then reboot when a new deployment is staged
```

---

## Still stuck?

| Resource | Use when |
|----------|----------|
| [INSTALL.md](../INSTALL.md) | Re-check install path |
| [first-boot.md](first-boot.md) | What “healthy” first session looks like |
| [updating.md](updating.md) | Upgrade / reboot confusion |
| [architecture.md](architecture.md) | Why skel / immutable base behave this way |
| [security.md](security.md) | Auth, immutability, optional duress (off) |
| [screenshots.md](screenshots.md) | Capture notes for bug reports / handbook media |
| GitHub issues on the hyprwave repo | Bugs in the image |

Avoid reading `planning/` unless you are a contributor; it is design history, not user support.
Lane integration trees (`a-stabilize`, `d-duress`, `e-hyprland`, `f-cosmic`, `g-qa`) may
exist only on their branches until Wave 1 merges.
