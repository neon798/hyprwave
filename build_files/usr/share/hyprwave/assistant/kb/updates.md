# How Updates Work

Hyprwave separates **base image** updates from **app** updates.

## Base system (bootc)

```bash
bootc status          # what is booted / staged
sudo bootc upgrade    # pull and stage the next image
sudo systemctl reboot # apply staged deployment
```

- Changes are **staged** until reboot.
- Previous deployments remain available for rollback.
- The Assistant **Updater** tab runs status + upgrade with a reboot warning.

## Flatpak apps

```bash
flatpak update
```

- No reboot required for most apps.
- User and system Flatpaks can both be present; the Assistant uses `flatpak update -y`.

## Update all (recommended order)

1. Update Flatpaks (quick, no reboot).
2. Upgrade the base image.
3. Reboot when bootc reports a staged deployment.

## Rebase (switch Hyprland ↔ COSMIC)

```bash
# Example — use your registry/owner if different
sudo bootc switch ghcr.io/neon798/hyprwave:latest
sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest
sudo systemctl reboot
```

Rebase is a full image switch, not a package toggle. Your home directory is kept; greeter and session defaults follow the image.

## Rollback

If an update misbehaves, boot a previous deployment from the bootloader or use bootc/ostree rollback tooling, then report the issue with `bootc status` output.
