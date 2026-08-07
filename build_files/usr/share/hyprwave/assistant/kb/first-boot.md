# First Boot

What to expect the first time you log into Hyprwave.

## Greeter

- **Hyprland image** — typically SDDM; pick the Hyprland session.
- **COSMIC image** — cosmic-greeter; pick the COSMIC session.

## First login checklist

1. A new user gets defaults from `/etc/skel` (themes, Hyprland/COSMIC config, Ghostty, Walker, etc.).
2. Desktop tools start from autostart (Walker/elephant on Hyprland, COSMIC shell on cosmic).
3. Wallpapers come from the active theme (hyprpaper on Hyprland — see hyprpaper article).
4. Network is required for Flatpak installs and image upgrades; **KB works offline**.

## Suggested first steps

1. Confirm the desktop feels right (`hyprwave-theme list` / `set`).
2. Open **Hyprwave Assistant** (menu, `hyprwave-assistant`, or Super+Shift+A once bound).
3. Read Knowledge Base → Philosophy + Updates (no network needed).
4. Run **Updater → refresh** or `hyprwave-assistant status`.
5. Install apps via Installer (curated) or **FlatArcade** (full Flathub) when online.

## Existing vs new users

Skel only applies to **new** accounts. If you upgraded the image, old homes keep old configs. Diff against `/etc/skel` or create a test user to see current defaults.

## If something is wrong

See Troubleshooting. Prefer rolling back a bad base deployment over fighting a half-updated system. The Assistant never forces reboot.
