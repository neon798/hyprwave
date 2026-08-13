# Extending the System

How to add software without fighting the immutable base.

## Prefer Flatpak

```bash
flatpak install -y flathub <app-id>
# or: hyprwave-assistant install <catalog-id> --yes
# or: FlatArcade
```

Sandboxed, updatable, no rebase required.

## Distrobox for mutable environments

When you need a classic package manager for development:

```bash
distrobox create --name dev
distrobox enter dev
```

(Distrobox may be layered on the host — see catalog entry notes.)

## Layering (use sparingly)

Host packages change the image contract and complicate support. Prefer:

1. Flatpak  
2. Distrobox  
3. Rebuild / rebase a custom bootc image  

The Assistant will **not** silently layer packages; layer catalog entries print instructions only.

## Config

- Hyprland fragments: `~/.config/hypr/`
- Themes: `hyprwave-theme`
- User scripts: your home directory (survives rebases)

## Contributing

Theme packs, KB articles, and catalog entries live in the Hyprwave image repo under `build_files/usr/share/hyprwave/`.
