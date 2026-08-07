# Variants: Hyprland vs COSMIC

Hyprwave publishes two related images from the same repo:

| Image | Desktop | Greeter (typical) |
|-------|---------|-------------------|
| `hyprwave` | Hyprland | SDDM |
| `hyprwave-cosmic` | Fedora COSMIC | cosmic-greeter |

## Shared components

Both variants aim to ship the same companion story:

- Ghostty, Yazi, Neonwolf, FlatArcade
- Hyprwave theme assets where applicable
- Immutable bootc update model
- This Assistant (once integrated into the image)

## Differences you will notice

- **Launcher / shell** — Walker + Waybar on Hyprland; COSMIC shell/panels on cosmic.
- **Keybindings** — Hyprland uses Super-centric binds documented in the keybindings article; COSMIC uses its own shortcuts.
- **Theming** — Hyprland themes cover bar/launcher/notifications; COSMIC themes focus on `~/.config/cosmic/` vendor keys + wallpaper.
- **Session** — pick the session at the greeter after a rebase, or rebase fully to the other image.

## Choosing

- Prefer **Hyprland** for tiling, keyboard-driven workflow, and the full synthwave bar/launcher stack.
- Prefer **COSMIC** for a more traditional desktop shell while keeping Hyprwave branding and tools.

Switch with `bootc switch` (see the Updates article), then reboot.
