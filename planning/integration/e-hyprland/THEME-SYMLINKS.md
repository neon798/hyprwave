# Theme symlink layout (Hyprland skel)

**Audience:** skel maintainers (Model E), theme pack owners, QA.  
**Runtime switcher:** `/usr/bin/hyprwave-theme` (not skel; retargets indirection + reloads daemons).

## Model

```
~/.config/hyprwave/theme          →  absolute link to active pack
                                     /usr/share/hyprwave/themes/<name>

App configs under ~/.config use *relative* links through that indirection:

  looknfeel / waybar CSS / mako / ghostty colors / walker CSS
       └─→  ../hyprwave/theme/...   (or deeper ../../../ for walker theme dir)
```

Changing the active theme only rewrites **one** symlink
(`~/.config/hyprwave/theme`). Relative links keep working; no per-app relinking
on every switch.

## Skel inventory (shipped)

| Skel path | Link target | Resolves (default pack) |
|-----------|-------------|-------------------------|
| `.config/hyprwave/theme` | `/usr/share/hyprwave/themes/hyprwave` | active pack root |
| `.config/hypr/looknfeel.conf` | `../hyprwave/theme/hypr/looknfeel.conf` | borders, gaps, animations |
| `.config/waybar/style.css` | `../hyprwave/theme/waybar/style.css` | bar chrome |
| `.config/mako/config` | `../hyprwave/theme/mako/config` | notifications |
| `.config/ghostty/theme.conf` | `../hyprwave/theme/ghostty/config` | terminal palette |
| `.config/walker/themes/hyprwave/style.css` | `../../../hyprwave/theme/walker/style.css` | launcher CSS |

Walker’s **theme name** in `config.toml` stays `"hyprwave"` so it always loads
`~/.config/walker/themes/hyprwave/`. Only the CSS file inside that directory is
indirection-linked; `layout.xml` is a normal skel file (structure, not palette).

Ghostty main `config` uses `config-file = ?theme.conf` (`?` = optional) so a
missing theme file does not hard-fail the terminal.

## Not themed via symlink (by design)

| Component | Why |
|-----------|-----|
| `hyprlock.conf` | Brand lock chrome; wallpaper fixed at `/usr/share/hyprwave/wallpapers/default.png` |
| `hyprpaper.conf` | **Rewritten as a file** by `hyprwave-theme` (preload/wallpaper paths per pack) |
| `waybar/config.jsonc` | Module layout, not colors |
| `walker/config.toml` | Providers/prefixes, not colors |
| `bindings.conf` / `autostart.conf` | Session behavior |

## Verify on a live user

```bash
# Indirection
readlink -f ~/.config/hyprwave/theme
# expect: /usr/share/hyprwave/themes/<name>

# Relative chain still lands in the pack
readlink -f ~/.config/waybar/style.css
readlink -f ~/.config/hypr/looknfeel.conf
readlink -f ~/.config/mako/config
readlink -f ~/.config/ghostty/theme.conf
readlink -f ~/.config/walker/themes/hyprwave/style.css

# Switch and re-check
hyprwave-theme list
hyprwave-theme set vaporwave   # example pack name
readlink -f ~/.config/hyprwave/theme
# waybar/mako should retint without logout (switcher sends SIGUSR2 / makoctl)
```

## Broken-link triage

| Symptom | Check |
|---------|--------|
| Unstyled bar | `readlink -f ~/.config/waybar/style.css` missing → pack missing `waybar/style.css` (theme pack bug → HANDOFF / theme owner) |
| Default Hyprland look only | `looknfeel.conf` dangling → pack missing `hypr/looknfeel.conf` |
| Walker looks stock | CSS symlink broken or Walker theme name ≠ `hyprwave` |
| Ghostty default colors | `theme.conf` dangling or `config-file = ?theme.conf` removed |

**Skel policy:** fix broken *relative* links under exclusive skel paths. Do **not**
mass-edit `/usr/share/hyprwave/themes/**` from this lane — open HANDOFF if a pack
file is missing.

## Default pack expectation

Every theme directory under `/usr/share/hyprwave/themes/<name>/` should provide
at least:

- `hypr/looknfeel.conf`
- `waybar/style.css`
- `mako/config`
- `ghostty/config`
- `walker/style.css`
- `wallpapers/` (used by switcher for hyprpaper, not by skel symlinks)

Audit of skel links against default `hyprwave` pack (E-W1-002): all five relative
links match pack layout; indirection absolute path is valid.
