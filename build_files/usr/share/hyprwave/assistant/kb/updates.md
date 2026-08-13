# How Updates Work

Hyprwave separates **base image** updates from **app** updates. Prefer Flatpak for apps; leave the base image immutable.

## Base system (bootc)

```bash
bootc status          # what is booted / staged
sudo bootc upgrade    # pull and stage the next image
sudo systemctl reboot # apply staged deployment
```

- Changes are **staged** until reboot.
- Previous deployments remain available for rollback.
- The Assistant **Updater** tab runs status + upgrade with dry-run / double-confirm and a reboot reminder.
- Assistant **never** reboots the host.
- Pull failures (401/403) often mean **GHCR is private** — see **`ghcr`**.
- `hyprwave-assistant status` prints the booted image ref and a short note:
  GHCR may need auth; **localhost** tags are valid for local builds.

CLI:

```bash
hyprwave-assistant status
hyprwave-assistant status --check
hyprwave-assistant update --base --dry-run
hyprwave-assistant update --base --yes --confirm   # mutates when online + privileged
```

## Flatpak apps

```bash
flatpak update
# or
hyprwave-assistant update --flatpak --dry-run
hyprwave-assistant update --flatpak --yes --confirm
```

- No reboot required for most apps.
- User and system Flatpaks can both be present; Assistant uses non-interactive Flatpak flags in its plan.

## Update all (recommended order)

1. Update Flatpaks (quick, no reboot).
2. Upgrade the base image.
3. Reboot when bootc reports a staged deployment.

```bash
hyprwave-assistant update --all --dry-run
hyprwave-assistant update --all --yes --confirm
```

## Rebase (switch Hyprland ↔ COSMIC)

Rebase is **not** the same as upgrade. Full user story: open article **`bootc-rebase`**.

```bash
# Example — use your registry/owner if different
sudo bootc switch ghcr.io/neon798/hyprwave:latest
sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest
sudo systemctl reboot
```

Rebase is a full image switch, not a package toggle. Your home directory is kept; greeter and session defaults follow the image. Skel does not rewrite existing homes.

## GHCR may be private

`bootc upgrade` / `switch` pull from GHCR (`ghcr.io/neon798/hyprwave[:cosmic]`). If the package is private, pulls fail with **401/403**. That is registry visibility, not a bad command. See article **`ghcr`**.

## Offline

| Works offline | Needs network |
|---------------|---------------|
| `status` of local tools | `bootc upgrade` / `switch` |
| KB + catalog | `flatpak update` / install |
| `--dry-run` plans | live remote operations |

When offline, Assistant shows a clear **OFFLINE** banner and refuses remote mutations.

## Rollback

If an update misbehaves, boot a previous deployment from the bootloader or use bootc/ostree rollback tooling, then report the issue with `bootc status` output.

## Related

- `ghcr` — registry 401/403
- `bootc-rebase` — variant switch
- `first-boot` — after a new image boots
