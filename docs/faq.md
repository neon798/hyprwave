# FAQ

Short answers for operators. Deeper detail links to the rest of the handbook.

---

### 1. What is Hyprwave?

An immutable **bootc** (bootable container) OS image based on Fedora Atomic / Universal
Blue, with either **Hyprland** or **COSMIC** as the desktop and a shared synthwave
identity (Neonwolf, FlatArcade, themes).

See [architecture.md](architecture.md).

---

### 2. How do I install on a machine that already has bootc?

```bash
sudo bootc switch ghcr.io/neon798/hyprwave:latest   # or hyprwave-cosmic
sudo systemctl reboot
```

Full paths (ISO, private registry): [INSTALL.md](../INSTALL.md).

---

### 3. `bootc switch` / `podman pull` returns 401 or 403 — is the image broken?

Often the GHCR package is **private** or you need credentials. Docs do **not** claim
the registry is public. Try `podman pull ghcr.io/neon798/hyprwave:latest`, then see
[troubleshooting.md](troubleshooting.md#install--registry) and INSTALL’s contingency
(build ISO / local image).

---

### 4. How do I update the OS vs apps?

| Layer | Command |
|-------|---------|
| Base image (same ref) | `sudo bootc upgrade` then **reboot** |
| Change Hyprland ↔ COSMIC | `sudo bootc switch …` then reboot |
| Flatpak apps | `flatpak update` or **FlatArcade** |

Details: [updating.md](updating.md).

---

### 5. I upgraded the image but my desktop config did not change. Why?

`/etc/skel` applies only when a **user account is created**. Existing
`~/.config` is never overwritten by a normal image upgrade. Copy carefully from
`/etc/skel/` or create a new user. [architecture.md](architecture.md#default-user-configs-etcskel).

---

### 6. Hyprland or COSMIC — which should I pick?

| Choose Hyprland if… | Choose COSMIC if… |
|---------------------|-------------------|
| You want tiling + Super keybinds, Walker, Waybar | You want a full DE (dock, settings, greeter) |
| You like hypr ecosystem tools | You still want Neonwolf / FlatArcade / themes |

Switch later with `bootc switch`. [cosmic.md](cosmic.md).

---

### 7. What is the app launcher? (Is it Wofi?)

**Walker** (with **elephant** plugins). **Wofi is not used.**  
Hyprland: Super+D or Super+Space. [keybinds.md](keybinds.md).

---

### 8. How do wallpapers work? (Is it swaybg?)

On the Hyprland image, **hyprpaper** (autostarted). **swaybg is not used.**  
Themes set wallpapers via `hyprwave-theme`. [theming.md](theming.md),
[troubleshooting.md](troubleshooting.md#no-wallpaper).

---

### 9. How do I change the look (themes)?

```bash
hyprwave-theme list
hyprwave-theme set vaporwave
```

Or **Hyprwave Themes** GUI / Super+Shift+T on Hyprland. Eleven packs under
`/usr/share/hyprwave/themes/`. [theming.md](theming.md).

---

### 10. How do I install graphical apps?

Use **FlatArcade** (Flathub TUI) or `flatpak install`. Stock Firefox is not the default
browser — use **Neonwolf**. There is no traditional full-OS `dnf install` of the
immutable base; layering is an advanced Atomic topic.

---

### 11. Where is the file manager? (Thunar?)

Default file manager is **Yazi** (terminal UI). Hyprland opens it with Super+E in
Ghostty. COSMIC also ships Cosmic Files. **Thunar is not the default.**

---

### 12. Walker opens but shows no apps — what now?

Elephant must be running; restart the walker user service. See
[troubleshooting.md](troubleshooting.md#walker-empty--no-apps--does-nothing).

---

### 13. What greeter do I get at boot?

| Image | Greeter |
|-------|---------|
| `hyprwave` | **SDDM** (synthwave theme) |
| `hyprwave-cosmic` | **cosmic-greeter** |

---

### 14. Is there a duress / wipe password?

Optional duress packaging may exist in the project as **off-by-default** assets. Stock
installs do **not** enable it. Do not assume a second password exists.
[security.md](security.md).

---

### 15. Will Hyprwave Assistant manage updates for me?

**Hyprwave Assistant** ships in the image (`hyprwave-assistant`). On Hyprland, open it
with **Super+Shift+A** (or the desktop entry). It is a convenience TUI for `bootc`
status/upgrade, Flatpak, a curated catalog, and offline KB — confirm destructive
actions, and still **reboot** after a base upgrade. You can always use
`sudo bootc upgrade` and FlatArcade instead.
[updating.md](updating.md), [keybinds.md](keybinds.md).

---

### 16. Can I roll back a bad upgrade?

bootc/Atomic systems keep previous deployments. Use your host’s rollback flow
(`bootc` / `rpm-ostree` docs for your base) and confirm with `bootc status`.
[updating.md](updating.md#rollbacks).

---

### 17. NVIDIA black screen after login?

Not hardware-certified in this repo. Check TTY logs and drivers; see
[troubleshooting.md](troubleshooting.md#black-screen-after-sddm-login). Prefer open
stacks where possible.

---

### 18. How do I build from source?

```bash
just build hyprwave latest
just build-cosmic
just build-iso    # needs sudo
```

[INSTALL.md](../INSTALL.md#path-c--developers-local-image--vm), contributor notes
in [contributor-notes.md](contributor-notes.md).

---

## Still stuck?

[troubleshooting.md](troubleshooting.md) · [docs/README.md](README.md)
