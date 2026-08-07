# How Updates Work in Hyprwave

Hyprwave is an **immutable bootc image**.

## Base System Updates
- Use `bootc update` (or the Assistant)
- This updates the entire OS image atomically
- Changes are staged — you usually need to **reboot** to apply
- Previous images are kept for rollback

## Flatpak Updates
- User and system Flatpaks are updated separately
- `flatpak update`
- No reboot required for most apps

## Rebase (Switching Variants)
- `sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest`
- Switches between Hyprland and COSMIC images

The Assistant's Updater tab combines these into one convenient place.

See also: Rebase between variants, Rollback
