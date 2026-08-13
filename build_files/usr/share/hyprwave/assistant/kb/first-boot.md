# First Boot

What to expect the first time you log into Hyprwave. Dual desktop variants ship from the same repo.

## Which desktop?

| Image | Greeter | Desktop stack |
|-------|---------|---------------|
| `hyprwave` | SDDM | Hyprland + **Walker** + Waybar + mako + **hyprpaper** |
| `hyprwave-cosmic` | cosmic-greeter | Fedora COSMIC shell (own launcher/panel) |

Both share Ghostty, Yazi, Neonwolf, FlatArcade, **11 themes**, and Hyprwave Assistant.

## Greeter

- **Hyprland image** — SDDM; pick the Hyprland session.
- **COSMIC image** — cosmic-greeter; pick the COSMIC session.

## First login checklist

1. **New users only** get `/etc/skel` defaults (Hyprland/COSMIC config, Ghostty, Walker, theme pointer). Existing homes are not rewritten on upgrade or rebase.
2. Hyprland autostart brings up **hyprpaper** (wallpaper — not swaybg), mako, waybar, elephant + Walker.
3. Default theme pack is **hyprwave** (synthwave). There are **11** packs: `hyprwave-theme list`.
4. **Hyprwave Assistant is installed** (`/usr/bin/hyprwave-assistant`). On Hyprland: **Super+Shift+A** (Ghostty). Also the app menu / `hyprwave-assistant`.
5. **Duress is OFF** in the stock image (packaging may exist; PAM is not enabled).
6. Network is required for Flatpak installs and image upgrades; **KB works offline**.
7. If `bootc upgrade` / `podman pull` returns **401/403**, **GHCR may be private** — see article `ghcr`.

## Suggested first steps

1. Confirm the desktop (`hyprwave-theme list` / `set`, or Super+Shift+T on Hyprland).
2. Open Assistant (**Super+Shift+A** on Hyprland).
3. Read Knowledge Base → Philosophy + Updates (no network needed).
4. Run **Updater → refresh** or `hyprwave-assistant status`.
5. Install apps via Installer (curated) or **FlatArcade** (full Flathub) when online.

## Existing vs new users

Skel applies to **new accounts only**. After an image upgrade, old homes keep old configs. Diff against `/etc/skel` or create a test user to see current defaults.

## If something is wrong

See Troubleshooting. Prefer rolling back a bad base deployment over fighting a half-updated system. The Assistant never forces reboot.
