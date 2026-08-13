# First boot handbook

What to expect from login through a working desktop on either Hyprwave variant.
This is the **end-user** path. Integrator / VM operators also use the longer validation
checklist:

- [planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md](../planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md)
  — greeter, skel, Ghostty, Walker, companions, theme, NetworkManager, GHCR pull notes.

Install methods: [INSTALL.md](../INSTALL.md). Updates later: [updating.md](updating.md).

### How you should have gotten the image (today)

| How you installed | Image ref you should see | Greeter |
|-------------------|--------------------------|---------|
| **Local build + VM/ISO** (Path C/B) — **recommended** while GHCR is private | `localhost/hyprwave:latest` or `localhost/hyprwave-cosmic:latest` (after `just build hyprwave latest` / `just build-cosmic`) | SDDM / cosmic-greeter |
| **Authenticated** `bootc switch` to GHCR (Path A) | `ghcr.io/neon798/hyprwave:latest` or `…-cosmic:latest` | SDDM / cosmic-greeter |
| Anonymous `podman pull` / `bootc switch` to GHCR | **Usually fails with 403** — not a supported public path yet | — |

Do not assume GHCR is public. If install failed at pull time, rebuild locally:
[INSTALL.md — Path C](../INSTALL.md#path-c-local).

---

## 0. Which image am I on?

```bash
bootc status
```

| Image ref (typical) | Greeter | Desktop |
|---------------------|---------|---------|
| `localhost/hyprwave:latest` or `…/hyprwave:latest` | **SDDM** | Hyprland + Waybar, Walker, Mako, hyprpaper |
| `localhost/hyprwave-cosmic:latest` or `…/hyprwave-cosmic:latest` | **cosmic-greeter** | Fedora COSMIC + Hyprwave vendor theme |

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
   greeter face. Operator notes:
   - [GREETER.md](../planning/integration/f-cosmic/GREETER.md)
   - [SESSION-SMOKE.md](../planning/integration/f-cosmic/SESSION-SMOKE.md)
2. Select the **COSMIC** session and sign in.

---

## 2. First look after login

### Hyprland

Autostart (skel `autostart.conf`) brings up roughly:

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
- If `bootc upgrade` or `bootc switch` fails with **403**, GHCR is **private to
  anonymous clients** — use a local image (rebuild / Path C) or authenticate. See
  [INSTALL.md](../INSTALL.md#important-ghcr-is-private-anonymous-pull-fails) and
  [troubleshooting](troubleshooting.md#install--registry).
- Companion pins live in `build_files/versions.env` on `main`. A published GHCR
  `:latest` only matches this tree after a post-merge rebuild — confirm with
  `bootc status`. Operator notes:
  [RELEASE.md](../planning/integration/a-stabilize/RELEASE.md).

---

## 6. Optional next steps

1. Install apps you need via **FlatArcade** (Flathub).
2. Read the [FAQ](faq.md) (skel upgrades, dual variant, duress **off by default**).
3. Security overview: [security.md](security.md).
4. If something fails, start with [troubleshooting.md](troubleshooting.md).

### Also on the image (optional)

- **Hyprwave Assistant** — offline TUI (Hyprland: Super+Shift+A). Not required to
  use the desktop.

### What is *not* on by default

- **Duress / wipe password** — packaging ships; PAM is **never** enabled as stock
  login. See [security.md](security.md).

---

## 7. Operator paths (not required to use the OS)

Operator / integrator paths (all on `main` after Wave 1):

| Path | When |
|------|------|
| [FIRST-BOOT-CHECKLIST.md](../planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md) | VM / ship validation |
| [KEYBIND-MAP.md](../planning/integration/e-hyprland/KEYBIND-MAP.md) | Hyprland binds |
| [SESSION-SMOKE.md](../planning/integration/e-hyprland/SESSION-SMOKE.md) | Hyprland session smoke |
| [GREETER.md](../planning/integration/f-cosmic/GREETER.md) | cosmic-greeter limits |
| [f-cosmic/SESSION-SMOKE.md](../planning/integration/f-cosmic/SESSION-SMOKE.md) | COSMIC session smoke |
| [SMOKE-MATRIX.md](../planning/integration/g-qa/SMOKE-MATRIX.md) | Dual-variant matrix |
| [ACCURACY-AUDIT](../planning/integration/b-docs/ACCURACY-AUDIT.md) | Docs source map |

Handbook pages under `docs/` stay usable without the other lanes.
