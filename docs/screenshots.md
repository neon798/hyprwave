# Screenshots (handbook media)

Hyprwave’s user docs are written to work **without** embedded marketing images.
When captures exist, they live under a reserved tree and are wired with explicit
alt text.

| | |
|--|--|
| **Ops checklist** | [screenshot-checklist.md](../planning/integration/b-docs/screenshot-checklist.md) |
| **Reserved asset dir** | `docs/assets/` (preferred) or `docs/images/` |
| **Default theme for shots** | `hyprwave` pack |
| **Do not** | Commit large binaries unless tiny placeholders; block INSTALL on missing PNGs |

## Capture quick reference

### Hyprland image

| Action | How |
|--------|-----|
| Region → file | **Super+Shift+S** or `hyprshot -m region -o ~/Pictures` |
| Full output → file | **Super+Ctrl+Shift+S** or `hyprshot -m output -o ~/Pictures` |
| Walker / terminal / themes | Super+D · Super+Return · Super+Shift+T |

Full bind list: [keybinds.md](keybinds.md).

### COSMIC image

Use the desktop’s screenshot UI, or if available:

```bash
grim ~/Pictures/cosmic-$(date +%Y%m%d-%H%M%S).png
grim -g "$(slurp)" ~/Pictures/region.png
```

### No compositor on the capture host?

**Blocker:** SSH-only or headless hosts cannot run hyprshot/grim against a user session.
Boot a VM (`just run-vm-qcow2` / `just run-vm-qcow2-cosmic`) and use the viewer’s
screenshot, or capture inside the guest session.

Private GHCR (403) is not a screenshot tool failure — build a local image first
([INSTALL.md](../INSTALL.md)).

## Checklist summary

| Series | Count | Status |
|--------|-------|--------|
| Hyprland (H1–H11) | 11 | TODO (no binaries) |
| COSMIC (C1–C5) | 5 | TODO |
| Motion (M1–M2) | 2 | TODO |

Every row has **purpose**, **alt text**, and an **exact capture command** in the
checklist. After files land:

```bash
mkdir -p docs/assets
# cp ~/Pictures/….png docs/assets/<name>.png
```

Then embed from README / handbook pages with the alt text from the checklist and
mark rows `CAPTURED` / `IN_README`.

## Related

- [first-boot.md](first-boot.md) — what a healthy session looks like  
- [theming.md](theming.md) — theme packs for variety shots  
- [cosmic.md](cosmic.md) — COSMIC-only framing  
- [troubleshooting.md](troubleshooting.md) — if greeter/session never appears  
