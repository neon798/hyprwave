# Troubleshooting

Quick fixes for common Hyprwave issues. For install steps see [INSTALL.md](../INSTALL.md).
For how the image is structured see [architecture.md](architecture.md).

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

| Variant | Expected greeter |
|---------|------------------|
| Hyprland image | **SDDM** |
| COSMIC image | **cosmic-greeter** |

On a TTY:

```bash
systemctl status display-manager.service
systemctl status sddm.service          # Hyprland image
systemctl status cosmic-greeter.service  # COSMIC image
journalctl -b -u display-manager.service --no-pager | tail -80
```

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

Walker 2.x needs the **elephant** daemon and plugins.

```bash
pgrep -a elephant
pgrep -a walker
systemctl --user restart app-walker@autostart.service
# if the unit name differs on your session:
systemctl --user list-units '*walker*' '*elephant*'
```

Also:

- Icon themes: after adding icons on a custom image, `gtk-update-icon-cache` may be needed
  (image builds already refresh hicolor when packaging).
- Open Walker with **Super+D** or **Super+Space** (see [keybinds.md](keybinds.md)).

### Themes GUI / CLI does nothing

```bash
hyprwave-theme list
hyprwave-theme set vaporwave
# GUI
hyprwave-theme-gui
# or Super+Shift+T
```

- **Hyprland:** should live-reload bar/launcher/borders; open a **new** Ghostty window for terminal colors.
- **COSMIC:** some appearance keys need a short wait or session restart.
- Existing users without skel symlinks: ensure `~/.config/hyprwave/theme` points at a pack under
  `/usr/share/hyprwave/themes/`.

### Keybinds not working

Defaults live in `~/.config/hypr/bindings.conf`. If you overwrote skel early, restore from
`/etc/skel/.config/hypr/bindings.conf`. Super = Windows key.

---

## COSMIC session

See [cosmic.md](cosmic.md) for the full comparison. Short checks:

- Greeter is **cosmic-greeter**, not SDDM.
- No Walker/Waybar — use COSMIC launcher and panel.
- Themes: still `hyprwave-theme` / **Hyprwave Themes** app.
- Dock favorites should include Neonwolf, Ghostty, FlatArcade on a fresh vendor config.

---

## Apps

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
| [updating.md](updating.md) | Upgrade / reboot confusion |
| [architecture.md](architecture.md) | Why skel / immutable base behave this way |
| [security.md](security.md) | Auth, immutability, optional duress (off) |
| GitHub issues on the hyprwave repo | Bugs in the image |

Avoid reading `planning/` unless you are a contributor; it is design history, not user support.
