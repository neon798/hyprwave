# First boot handbook

What to expect from login through a working desktop on either Hyprwave variant.
This is the **end-user** path. Integrator / VM operators also use the longer validation
checklist on Model A’s lane (path may exist only on **`lane/a-stabilize`** until merge):

- `planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md` — greeter, skel, Ghostty,
  Walker, companions, theme, NetworkManager, GHCR pull notes.

Install methods: [INSTALL.md](../INSTALL.md). Updates later: [updating.md](updating.md).

---

## 0. Which image am I on?

```bash
bootc status
```

| Image ref (typical) | Greeter | Desktop |
|---------------------|---------|---------|
| `…/hyprwave:latest` | **SDDM** | Hyprland + Waybar, Walker, Mako, hyprpaper |
| `…/hyprwave-cosmic:latest` | **cosmic-greeter** | Fedora COSMIC + Hyprwave vendor theme |

Both share Neonwolf, FlatArcade, Yazi, Ghostty, fonts, wallpapers, and
`hyprwave-theme`. See [cosmic.md](cosmic.md) for COSMIC-only differences.

**Skel caveat:** defaults under `/etc/skel` apply when the **user account is created**.
Upgrades and rebases do **not** rewrite an existing `~/.config`. Details:
[architecture.md](architecture.md).

---

## 1. Login (greeter)

### Hyprland — SDDM

1. Boot to the synthwave SDDM theme (“HYPRWAVE” title, purple card).
2. Choose the Hyprland session if more than one is listed.
3. Sign in with the user created at install (or by the host admin).

If the screen stays black after password: [troubleshooting — black screen](troubleshooting.md#black-screen-after-sddm-login).

### COSMIC — cosmic-greeter

1. Boot to **cosmic-greeter** (not SDDM). Greeter chrome may use upstream styling —
   Hyprwave wallpaper/theme is guaranteed for the **session**, not necessarily the
   greeter face. Lane docs (read-only, may be on branch only):
   - `planning/integration/f-cosmic/GREETER.md` on **`lane/f-cosmic`**
   - Session checks: `planning/integration/f-cosmic/SESSION-SMOKE.md` on **`lane/f-cosmic`**
2. Select the **COSMIC** session and sign in.

---

## 2. First look after login

### Hyprland

Autostart (skel `autostart.conf`, refined on `lane/e-hyprland`) brings up roughly:

| Piece | Role |
|-------|------|
| **hyprpaper** | Wallpaper early (not swaybg) |
| **mako** | Notifications |
| **waybar** | Status bar |
| **hypridle** | Idle → lock (hyprlock) |
| **elephant** + **walker --gapplication-service** | Launcher data + Walker service |
| **xdg-desktop-portal-hyprland** | Portals |

You should see wallpaper + bar within a few seconds. Empty launcher?
[troubleshooting — Walker](troubleshooting.md#walker-empty--no-apps--does-nothing).

### COSMIC

Expect panel/dock, Hyprwave default wallpaper
(`/usr/share/backgrounds/hyprwave/default.png` via vendor CosmicBackground), and dock
favorites (order on F lane): Neonwolf → FlatArcade → Ghostty → Cosmic Files →
Hyprwave Themes → Cosmic Settings. No Waybar/Walker required.

---

## 3. Five-minute tour (both variants)

| Goal | Hyprland | COSMIC |
|------|----------|--------|
| Terminal | **Super+Return** or **Super+T** → Ghostty | Dock **Ghostty** or launcher |
| Browser | **Super+B** → Neonwolf | Dock **Neonwolf** |
| App store | **Super+A** → FlatArcade (in Ghostty) | Dock **FlatArcade** |
| Files | **Super+E** → Yazi in Ghostty | **Cosmic Files** (and Yazi in a terminal) |
| Launcher | **Super+D** / **Super+Space** → Walker | COSMIC app launcher |
| Themes | **Super+Shift+T** or **Hyprwave Themes** app | Dock **Hyprwave Themes** or CLI |

Full Hyprland map: [keybinds.md](keybinds.md). Themes: [theming.md](theming.md).

### Theme switcher (first success)

```bash
hyprwave-theme list
hyprwave-theme current
hyprwave-theme set vaporwave   # example; try fjord-dark, etc.
```

Or open **Hyprwave Themes** GUI. Hyprland reloads chrome live; COSMIC writes
`~/.config/cosmic/` + wallpaper (a short wait or re-login may be needed).

Eleven packs live under `/usr/share/hyprwave/themes/`.

---

## 4. Confirm the system image

```bash
bootc status                 # booted / staged image
hostnamectl                  # optional host identity
```

If you rebased from another Atomic image, confirm the ref matches the variant you
wanted (`hyprwave` vs `hyprwave-cosmic`).

---

## 5. Update story (day one and later)

Stock day-to-day updates:

```bash
sudo bootc upgrade
sudo systemctl reboot
flatpak update               # apps installed via Flatpak / FlatArcade
```

- Full narrative: [updating.md](updating.md)
- If `bootc upgrade` or the first `bootc switch` fails with **403**, GHCR may still be
  **private** — that is a registry visibility issue, not a broken command. See
  [INSTALL.md](../INSTALL.md#important-ghcr-may-be-private) and
  [troubleshooting](troubleshooting.md#install--registry).
- Companion version pins and release operator notes live on **`lane/a-stabilize`**
  (`versions.env`, `planning/integration/a-stabilize/RELEASE.md`) until merged — do
  not assume every pin improvement is already on published `:latest`.

---

## 6. Optional next steps

1. Install apps you need via **FlatArcade** (Flathub).
2. Read the [FAQ](faq.md) (skel upgrades, dual variant, duress **off by default**).
3. Security overview: [security.md](security.md).
4. If something fails, start with [troubleshooting.md](troubleshooting.md).

### What is *not* on by default

- **Duress / wipe password** — optional packaging only; never enabled as stock login.
  See [security.md](security.md).
- **Hyprwave Assistant** and other Wave-1 lane features may be **pending merge** —
  [CHANGELOG.md](../CHANGELOG.md) lists lane status honestly.

---

## 7. Operator paths (not required to use the OS)

Lane integration trees may exist only on their branches until Wave 1 merges. Listed as
repo paths (not hard links) so this page stays valid on `main` without those files:

| Path | When / branch |
|------|----------------|
| `planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md` | VM / ship validation — `lane/a-stabilize` |
| `planning/integration/e-hyprland/KEYBIND-MAP.md` | Hyprland binds — `lane/e-hyprland` |
| `planning/integration/e-hyprland/SESSION-SMOKE.md` | Hyprland session smoke — `lane/e-hyprland` |
| `planning/integration/f-cosmic/GREETER.md` | cosmic-greeter limits — `lane/f-cosmic` |
| `planning/integration/f-cosmic/SESSION-SMOKE.md` | COSMIC session smoke — `lane/f-cosmic` |
| `planning/integration/g-qa/SMOKE-MATRIX.md` | Dual-variant matrix — `lane/g-qa` |
| [ACCURACY-AUDIT](../planning/integration/b-docs/ACCURACY-AUDIT.md) | Docs source map (this lane; always on `lane/b-docs`) |

Handbook pages under `docs/` stay usable without the other lanes.
