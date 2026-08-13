# GHCR may be private

Published Hyprwave images live on GitHub Container Registry:

```text
ghcr.io/neon798/hyprwave:latest
ghcr.io/neon798/hyprwave-cosmic:latest
```

**The packages may still be private.** Anonymous `bootc switch`, `bootc upgrade`, and `podman pull` can fail with **401/403**. That is a registry visibility setting, not a broken Hyprwave command.

## Test the pull (no switch)

```bash
podman pull ghcr.io/neon798/hyprwave:latest
# or
podman pull ghcr.io/neon798/hyprwave-cosmic:latest
```

| Result | What to do |
|--------|------------|
| Pull works | Use `sudo bootc switch` / `sudo bootc upgrade` as usual |
| 401/403 | Build a local image / ISO from this repo, wait for public GHCR, or `podman login ghcr.io` **only if you have access** |

## Already installed from a local/private image

`bootc upgrade` talks to the **same ref** you booted. If that ref is private, later upgrades need auth or a different published package.

```bash
bootc status
hyprwave-assistant status          # shows image ref + private-GHCR note when applicable
hyprwave-assistant status --check
```

**localhost tags are valid** for local builds (e.g. `localhost/hyprwave:latest` from `just build`). They are not a “broken” install and do not require anonymous GHCR pulls.

## What still works offline / without GHCR

- This Knowledge Base and the curated catalog
- Assistant dry-run plans
- Flatpak installs from Flathub (separate from GHCR)

## Related

- `updates` — day-to-day bootc + Flatpak
- `bootc-rebase` — Hyprland ↔ COSMIC switch
- `first-boot` — orientation
