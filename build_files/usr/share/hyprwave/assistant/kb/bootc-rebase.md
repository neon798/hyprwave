# Bootc rebase user story (Hyprland ↔ COSMIC)

Hyprwave is a **bootable container** (bootc) OS. Day-to-day package installs are discouraged on the base; apps prefer Flatpak. Switching desktop **variant** is an image rebase, not `dnf swap`.

## User story

> “I installed Hyprwave with Hyprland. I want to try the COSMIC image (or go back) without reinstalling from ISO and without losing my home directory.”

## What rebase does

- Pulls a different image ref and stages a new deployment
- Next reboot boots that deployment’s root filesystem (desktop, greeter defaults, system units)
- **`$HOME` is preserved** on the data volume
- Greeter, default session, and system-owned configs follow the **new image**
- Your user customizations under `~/.config` remain; some may be Hyprland-only or COSMIC-only

## Safe procedure

1. **Save work** and note any staged upgrade already pending:
   ```bash
   bootc status
   hyprwave-assistant status
   ```
2. **Optional:** update Flatpaks first so apps stay current across both variants:
   ```bash
   hyprwave-assistant update --flatpak --dry-run
   # when ready:
   hyprwave-assistant update --flatpak --yes --confirm
   ```
3. **Switch image** (example registry/owner — use your published refs):
   ```bash
   # Toward COSMIC
   sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest

   # Back to Hyprland
   sudo bootc switch ghcr.io/neon798/hyprwave:latest
   ```
4. **Reboot yourself** when status shows a staged deployment.  
   Assistant **never** reboots for you.
   ```bash
   sudo systemctl reboot
   ```
5. At the greeter, pick the session that matches the image (Hyprland or COSMIC).

## After first boot on the other DE

| Check | Why |
|-------|-----|
| `bootc status` | Confirms booted image ref |
| Theme | Run `hyprwave-theme list` / `set` for the DE you are on |
| Assistant | Same binary + data; Super+Shift+A if wired on Hyprland |
| Flatpaks | Usually still installed; open FlatArcade if something is missing |
| Hypr-only tools | Walker / Waybar only on Hyprland image |

## Upgrade vs rebase vs layer

| Action | Command idea | Result |
|--------|--------------|--------|
| Upgrade same stream | `sudo bootc upgrade` | Newer build of **current** image |
| Rebase variant | `sudo bootc switch <ref>` | Different image (e.g. cosmic ↔ hyprland) |
| Layer packages | advanced / discouraged | Mutates base; prefer Flatpak / distrobox |

Assistant Updater uses **upgrade** paths. Rebase is intentional and manual via `bootc switch` (documented here, not auto-run by Assistant).

## Rollback

If the new image misbehaves:

1. Reboot and select a previous deployment in the bootloader, **or** use bootc/ostree rollback tooling for your version.
2. Capture `bootc status` output when reporting issues.

## Offline note

`bootc switch` and `bootc upgrade` need network to pull layers. Offline, you can still:

- Read this KB and other articles
- Browse the curated catalog
- Dry-run plans in Assistant

## Related

- `updates` — day-to-day upgrade order
- `variants` — feature matrix Hyprland vs COSMIC
- `first-boot` — initial orientation
- `troubleshooting` — common failures
