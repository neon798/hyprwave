# First Boot

What to expect the first time you log into Hyprwave.

## Greeter

- **Hyprland image** — typically SDDM; pick the Hyprland session.
- **COSMIC image** — cosmic-greeter; pick the COSMIC session.

## First login

1. A new user gets defaults from `/etc/skel` (themes, Hyprland/COSMIC config, Ghostty, Walker, etc.).
2. Desktop tools start from autostart (Walker/elephant on Hyprland, COSMIC shell on cosmic).
3. Network is required for Flatpak installs and image upgrades.

## Suggested first steps

1. Confirm the desktop feels right (theme: `hyprwave-theme list` / `set`).
2. Open **Hyprwave Assistant** (menu or `hyprwave-assistant`) → Knowledge Base.
3. Run **Updater → refresh** or `hyprwave-assistant status`.
4. Install apps via Assistant Installer (curated) or **FlatArcade** (full Flathub).

## Existing vs new users

Skel only applies to **new** accounts. If you upgraded the image, old homes keep old configs. Diff against `/etc/skel` or create a test user to see current defaults.

## If something is wrong

See the Troubleshooting article. Prefer rolling back a bad base deployment over fighting a half-updated system.
