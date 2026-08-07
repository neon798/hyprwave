# Proposed README sections (integrator apply)

Model B **preferred not** to rewrite all of `README.md` during the parallel wave.
Apply these sections (or merge surgically) when integrating `lane/b-docs`.

Current README already covers: companion apps, SDDM theme detail, COSMIC variant,
themes list + `hyprwave-theme`. Gaps: top-level install path for the **default**
Hyprland image, link to INSTALL/CHANGELOG/keybinds, and language that still reads
somewhat like a developer README.

---

## Suggested top of README (after title blurb)

```markdown
## Install

Hyprwave ships as bootable container images:

| Variant | Image | Greeter |
|---------|-------|---------|
| Hyprland (default) | `ghcr.io/neon798/hyprwave:latest` | SDDM |
| COSMIC | `ghcr.io/neon798/hyprwave-cosmic:latest` | cosmic-greeter |

```bash
# Hyprland
sudo bootc switch ghcr.io/neon798/hyprwave:latest && sudo systemctl reboot

# COSMIC
sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest && sudo systemctl reboot
```

Full instructions (ISO builds, first login, updates): **[INSTALL.md](INSTALL.md)**.  
Hyprland shortcuts: **[docs/keybinds.md](docs/keybinds.md)**.  
What’s new: **[CHANGELOG.md](CHANGELOG.md)**.
```

---

## Suggested “Default stack” subsection (Hyprland)

```markdown
## Default stack (Hyprland)

| Piece | Choice |
|-------|--------|
| Compositor | Hyprland |
| Launcher | Walker (+ elephant) |
| Bar | Waybar |
| Notifications | Mako |
| Wallpaper | hyprpaper |
| Terminal | Ghostty |
| Browser | Neonwolf |
| Files | Yazi |
| App store | FlatArcade |
| Themes | 11 packs via `hyprwave-theme` / Super+Shift+T |
```

---

## Suggested developer footer (keep short)

```markdown
## Building from source

```bash
just build hyprwave latest
just build-cosmic
just build-iso / just build-iso-cosmic   # needs sudo
```

See [INSTALL.md](INSTALL.md) and [CLAUDE.md](CLAUDE.md) for build architecture.
This repository is a customized Universal Blue `image-template` fork; there is no
application “src/” tree — the product *is* the OS image.
```

---

## README cleanup notes for integrator

1. SDDM section is very long for end users — consider moving QML implementation
   detail to `docs/sddm.md` and leaving a short “synthwave login theme” blurb.
2. COSMIC section already has install commands; after adding top-level Install,
   dedupe the cosmic `bootc switch` bullet to a link.
3. Do not reintroduce Wofi, swaybg, or Thunar-as-default wording.
4. Optional badge: Cosign / GHCR once public pull is verified (Model A checklist).
