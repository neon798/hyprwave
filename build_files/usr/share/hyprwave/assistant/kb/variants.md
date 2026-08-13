# Variants: Hyprland vs COSMIC (dual-variant)

Hyprwave publishes two related images from the same repo:

| Image | Desktop | Greeter (typical) | Launcher / shell |
|-------|---------|-------------------|------------------|
| `hyprwave` | Hyprland | SDDM | Walker + Waybar + mako |
| `hyprwave-cosmic` | Fedora COSMIC | cosmic-greeter | COSMIC shell / panels |

## Shared components

Both variants aim to ship the same companion story:

- Ghostty, Yazi, Neonwolf, FlatArcade
- Hyprwave theme assets where applicable
- Immutable **bootc** update model
- Hyprwave Assistant (once integrated into the image)

## Differences you will notice

| Area | Hyprland | COSMIC |
|------|----------|--------|
| Window management | Tiling compositor, Super binds | COSMIC window model |
| App launcher | Walker (elephant plugins) | COSMIC launcher |
| Status bar | Waybar | COSMIC panel |
| Notifications | Mako | COSMIC notifications |
| Theming | Full theme pack (hypr/waybar/walker/…) | `cosmic/config` + wallpaper |
| Lock / idle | hyprlock / hypridle | COSMIC session tools |
| Suggested Assistant keybind | Super+Shift+A → Ghostty | Pin desktop entry / menu |

## Choosing

- Prefer **Hyprland** for tiling, keyboard-driven workflow, and the full synthwave bar/launcher stack.
- Prefer **COSMIC** for a more traditional desktop shell while keeping Hyprwave branding and tools.

## Switching (rebase)

Do **not** try to install both DEs side-by-side on one immutable root as a day-to-day workflow. Use bootc switch:

```bash
# Example registry/owner — use your published refs
sudo bootc switch ghcr.io/neon798/hyprwave:latest
sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest
# then reboot yourself — Assistant never forces reboot
sudo systemctl reboot
```

Full walkthrough: KB article **`bootc-rebase`**.

Rebase is a full image switch. Your home directory is kept; greeter and session defaults follow the image.

## Assistant on both

Updater / Installer / KB work the same on both variants:

- Binary: `/usr/bin/hyprwave-assistant`
- Data: `/usr/share/hyprwave/assistant/{catalog.toml,kb/*.md}`
- Desktop: `hyprwave-assistant.desktop` (Exec via Ghostty)

Theme accent detection is best-effort; COSMIC themes apply via `hyprwave-theme` copy into `~/.config/cosmic/`.
