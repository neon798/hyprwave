# Proposed README sections (integrator + Wave 2)

Wave 1 added a short Install block on `README.md`. Wave 2 expands the docs tree under
`docs/`; the integrator can fold the sections below for a cleaner end-user README.

**Do not claim Assistant or Duress as default-shipped** until merge + image hooks land.
Phrase as optional / upcoming.

---

## Docs link bar (after Install)

```markdown
**Docs:** [User guide index](docs/README.md) ·
[Install](INSTALL.md) ·
[Updating](docs/updating.md) ·
[Troubleshooting](docs/troubleshooting.md) ·
[Keybinds](docs/keybinds.md) ·
[COSMIC](docs/cosmic.md) ·
[Architecture](docs/architecture.md) ·
[Security](docs/security.md) ·
[Changelog](CHANGELOG.md)
```

---

## Default stack (Hyprland)

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

## GHCR note (keep near Install)

```markdown
> **Registry:** `ghcr.io/neon798/hyprwave` images may be private until GitHub Packages
> visibility is fixed. If `bootc switch` returns 403, build from source (see INSTALL)
> or wait for public packages.
```

---

## Upcoming (optional features — not stock until merged)

```markdown
## Upcoming (optional)

These may land from parallel workstreams; they are **not** required for a usable desktop:

| Feature | Status to document |
|---------|-------------------|
| **Hyprwave Assistant** | Go TUI for updates / Flatpak / knowledge base. Dormant until image integration; not assumed installed. |
| **Duress password** | Optional PAM tooling. **Off by default** even after packaging; never describe as enabled on a fresh install. See [docs/security.md](docs/security.md). |

When merged, link Assistant to its manpage/KB and Duress only to operator ENABLE docs
(not a one-liner enable in the README).
```

---

## Building from source (footer)

```markdown
## Building from source

```bash
just build hyprwave latest
just build-cosmic
just build-iso            # needs sudo
just build-iso-cosmic
```

See [INSTALL.md](INSTALL.md) and [docs/architecture.md](docs/architecture.md).
Contributor build guts: [CLAUDE.md](CLAUDE.md). The product *is* the OS image.
```

---

## Cleanup notes

1. Move long SDDM QML detail out of README into a short blurb + optional `docs/sddm.md`.  
2. Dedupe COSMIC install bullets now that INSTALL + `docs/cosmic.md` exist.  
3. Never reintroduce Wofi, swaybg, or Thunar-as-default.  
4. Screenshots: only embed when files exist (see screenshot-checklist.md).  
5. Assistant/Duress blurbs stay “upcoming / off by default” until integrator says otherwise.
