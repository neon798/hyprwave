# Accuracy audit (Model B — task B-W1-001)

**Date:** 2026-08-07  
**Branch:** `lane/b-docs`  
**Scope:** Handbook claims vs tree on this branch (+ read-only lane tips where noted)

## Method

1. Read skel and theme store paths listed below.  
2. Grep operator docs for removed defaults (Wofi, swaybg, Thunar-as-default).  
3. Confirm Justfile recipe names used in INSTALL.  
4. Confirm greeter / DE split from `build_files/build.sh` case arms.  
5. Relative-link resolution across `docs/**`, INSTALL, README, CHANGELOG.

## Sources checked (file paths)

| Claim area | Source path(s) |
|------------|----------------|
| Hyprland keybinds | `build_files/etc/skel/.config/hypr/bindings.conf` |
| Walker prefixes / theme name | `build_files/etc/skel/.config/walker/config.toml` |
| Autostart (elephant, waybar, mako, hyprpaper) | `build_files/etc/skel/.config/hypr/autostart.conf` |
| Theme pack list (11) | `build_files/usr/share/hyprwave/themes/*` |
| Theme switcher CLI | `build_files/usr/bin/hyprwave-theme` |
| Theme GUI desktop entry | `build_files/usr/share/applications/hyprwave-theme.desktop` |
| Hyprland vs COSMIC packages / greeters | `build_files/build.sh` (`DE=hyprland\|cosmic`, SDDM, cosmic-greeter) |
| ISO kickstart image refs | `disk_config/iso.toml`, `disk_config/iso-cosmic.toml` |
| Just recipes | `Justfile` (`build`, `build-cosmic`, `build-iso`, `build-iso-cosmic`, VM) |
| Product overview | `README.md` (branch) |
| Base image | `Containerfile` / `CLAUDE.md` (`ghcr.io/ublue-os/base-main`) |
| External pin intent (pending merge) | `origin/lane/a-stabilize:build_files/versions.env` (read-only) |
| GHCR public? | **Not verified public** — docs require contingency language |

## Removed-stack grep (operator docs)

Command:

```bash
rg -n 'Wofi|wofi|swaybg|Thunar' INSTALL.md CHANGELOG.md README.md docs/ \
  planning/integration/b-docs/*.md
```

**Expected:** only explicit “not used / replaced by” wording, never “default launcher is Wofi”, etc.

| Term | Allowed usage | Found as default? |
|------|---------------|-------------------|
| Wofi | Historical removal note | No |
| swaybg | Historical removal note | No |
| Thunar | Historical “not default” / Yazi | No |

## Claim checklist

| Claim | Verdict | Notes |
|-------|---------|-------|
| Launcher = Walker + elephant | OK | bindings + autostart + build.sh |
| Wallpaper = hyprpaper | OK | autostart; not swaybg |
| File manager = Yazi | OK | Super+E; not Thunar default |
| Browser = Neonwolf | OK | bindings + build.sh |
| App store = FlatArcade | OK | bindings + README |
| Terminal = Ghostty | OK | bindings |
| 11 themes | OK | 11 dirs under themes/ |
| Super+D/Space/R/Shift+T | OK | bindings.conf |
| SDDM on hyprland image | OK | build.sh enable + conf |
| cosmic-greeter on cosmic | OK | build.sh |
| GHCR public | **Not claimed** | INSTALL + FAQ contingency |
| Duress default on | **Not claimed** | security.md off-by-default |
| Assistant shipped on main | **Not claimed** | upcoming / pending merge |
| Pins on main | Documented as **pending merge** from A | versions.env on a-stabilize |

## Link check

Relative markdown links under handbook paths resolved with a local path walk (0 missing
at audit time). Re-run after large doc moves:

```bash
# from repo root — simple existence check for relative targets
python3 -c "..."  # or re-run Model B link script in WORK_LOG notes
```

## Gaps left for other lanes / integrator

| Gap | Owner |
|-----|-------|
| GHCR visibility / public pull proof | A / ops |
| Merge pins + features to main | Integrator |
| Actual screenshot binaries | B Wave media / G QA |
| Assistant image hook | C + integrator |
| Duress enable (never default) | D + human security review |

## Sign-off

Handbook language matches **lane product reality** for Walker / hyprpaper / Yazi / themes /
dual DE. Registry publicity and merge status are deliberately cautious.
