# FlatArcade vs Hyprwave Assistant

Both are TUI tools; they solve different jobs.

## FlatArcade

- Full **Flathub browser** / app store experience.
- Search the entire Flathub catalog, install, remove, update apps.
- Best when you know the app name or want to explore.

## Hyprwave Assistant

- **Curated** short list of popular software (Installer tab).
- **Base image** updates via bootc (with reboot warnings).
- **Knowledge Base** for how Hyprwave works.
- Not a replacement for FlatArcade’s full store UI.

## When to use which

| Goal | Tool |
|------|------|
| Browse all of Flathub | FlatArcade |
| One-click curated apps | Assistant → Installer |
| Update OS image | Assistant → Updater |
| Learn the distro | Assistant → Knowledge Base |
| Update only Flatpaks | Either (Assistant or `flatpak update`) |
