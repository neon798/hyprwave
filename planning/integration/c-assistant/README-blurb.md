# README blurb — Hyprwave Assistant (Wave 2)

## Hyprwave Assistant

TUI + CLI for **system updates**, a **curated installer**, and a short **knowledge base**.

```bash
hyprwave-assistant                 # TUI
hyprwave-assistant status --check  # bootc + flatpak + available updates
hyprwave-assistant update --dry-run
hyprwave-assistant update --yes    # mutate (needs privileges for bootc)
hyprwave-assistant list
hyprwave-assistant install libreoffice --dry-run
hyprwave-assistant kb updates
```

| Tab / command | Purpose |
|---------------|---------|
| Updater / `update` | `bootc upgrade`, `flatpak update` with confirm / `--yes`; **never reboots** |
| Installer / `install` | Curated Flathub IDs + layer notes |
| Knowledge Base / `kb` | First boot, updates, theming, Walker, variants, … |
| About | Version, theme, host tools |

Data: `/usr/share/hyprwave/assistant/`.  
Suggested keybind: **Super+Shift+A** → `ghostty -e hyprwave-assistant` (integrator applies to skel).

Not a FlatArcade replacement — FlatArcade browses all of Flathub.
