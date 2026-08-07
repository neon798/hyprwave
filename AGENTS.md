# AGENTS.md

> **Start with CLAUDE.md** — it covers the essential build commands, project structure, and workflow. This file adds technical patterns, gotchas, and implementation details that aren't immediately obvious from a surface-level read.

## Build Architecture

### Multi-stage container build
The `Containerfile` uses a **builder stage** (`hyprbuilder`) to compile Hyprland utilities from source, then COPYs only the runtime artifacts into the final image. The heavy `-devel` toolchain (gcc, cmake, Qt6-devel, etc.) never reaches the final image.

**Why source-built**: Fedora 44 doesn't package these tools (hyprland-qtutils, hyprpaper, hyprpicker, hyprsunset). The ashbuk COPR ships only the compositor, and solopasha's COPR is stale (Qt 6.10 / libdisplay-info 0.2) and conflicts with current F44 (Qt 6.11 / libdisplay-info 0.3).

**Version pins** (in `build-hypr-utils.sh`):
- hyprutils v0.13.1, hyprlang v0.6.8, hyprgraphics v0.5.1
- hyprland-qtutils v0.1.5, hyprpicker v0.4.7, hyprsunset v0.3.3, hyprpaper v0.7.6
- Qt 6.11 workaround: qtutils needs explicit `WaylandClientPrivate` in find_package (patched via sed)

### COPR repository pattern
COPRs (community repos for Hyprland, Walker, Ghostty) are **enabled before install, disabled after**. If you skip the disable step, they leak into the final image and cause issues for users.

```bash
# Top of build.sh
dnf5 -y copr enable ashbuk/Hyprland-Fedora
dnf5 -y copr enable errornointernet/walker
dnf5 -y copr enable scottames/ghostty

# ... installs ...

# Bottom of build.sh
dnf5 -y copr disable ashbuk/Hyprland-Fedora
dnf5 -y copr disable errornointernet/walker
dnf5 -y copr disable scottames/ghostty
```

**Gotcha**: COPR mirrors can be flaky. The build configures aggressive dnf retry settings (25 retries, 120s timeout) at the top of `build.sh`.

### AppImage extraction
Neonwolf browser ships as an AppImage, but it's **extracted at build time** to `/usr/lib/neonwolf/` so the runtime image doesn't need FUSE. The launcher script at `/usr/bin/neonwolf` just execs the extracted `AppRun`.

```bash
./neonwolf.AppImage --appimage-extract
mv /tmp/squashfs-root /usr/lib/neonwolf
rm -f /tmp/neonwolf.AppImage
```

### Walker theme structure
Walker's config lives under `build_files/etc/skel/.config/walker/`:

- **`config.toml`** — Walker 2.x settings: keyboard focus, selection wrap, theme name, provider prefixes, and an emergency restart action. Providers are configured via elephant plugins (no built-in providers in Walker 2.x).
- **`themes/hyprwave/style.css`** — GTK CSS for the synthwave look. Palette matches the rest of Hyprwave (bg `#15052e`, fg `#e0e0ff`, pink `#ff2d95`, cyan `#00f0ff`, purple `#b967ff`). Uses JetBrains Mono, hides scrollbars and subtext, highlights selections in cyan.
- **`themes/hyprwave/layout.xml`** — GTK4 XML layout: a centered `GtkWindow` with a search entry, list view, keybind hints, error label, and placeholder text. No hardcoded dimensions that would break on HiDPI.

Walker is launched from `autostart.conf` (`exec-once = elephant`) — the elephant daemon must be running before Walker can show results. Keybinds in `bindings.conf`:
- `Super + D` / `Super + Space` — open Walker
- `Super + R` — open Walker in runner mode (`walker --prefix ">"`)
- `XF86Search` — open Walker

**Gotcha**: Walker needs `gtk-update-icon-cache` refreshed for new icons to appear (see below), because GTK reads the prebuilt hicolor cache from the base image.

### Icon cache refresh
After adding icons (e.g., flatarcade.svg), **regenerate the hicolor icon cache** or GTK launchers (Walker) won't see them:

```bash
gtk-update-icon-cache -f /usr/share/icons/hicolor || true
```

The base image ships a prebuilt cache; without this step, GTK reads stale data.

## Package Installation Gotchas

### Walker + elephant plugins
Walker 2.x has no built-in providers — all data comes from **elephant plugins**. The `elephant` metapackage *Recommends* all ~18 plugins (~500 MB), so **disable weak deps** and install only what's needed:

```bash
dnf5 install -y --setopt=install_weak_deps=False \
    elephant \
    elephant-desktopapplications \
    elephant-calc \
    elephant-runner \
    elephant-menus \
    elephant-websearch \
    elephant-files \
    elephant-providerlist
```

### Runtime deps for source-built tools
The hypr utilities need specific runtime libraries (installed in `build.sh`):
- **hyprland-qtutils**: Qt6 Quick stack (qt6-qtbase-gui, qt6-qtdeclarative, qt6-qtwayland, qt6-qtsvg)
- **hyprpaper**: cairo/pango/glycin imaging
- **hyprpicker**: cairo/pango
- **hyprsunset**: hyprlang/hyprutils

These are the *runtime* deps only; the `-devel` toolchain stays in the throwaway builder stage.

## Dotfile Patterns

### Hyprland config structure
`hyprland.conf` only `source`s the fragment files — **edit the fragments, not the top-level file**:
- `envs.conf` — environment variables
- `monitors.conf` — display configuration
- `input.conf` — input devices
- `looknfeel.conf` — appearance (gaps, borders, blur, opacity, animations)
- `bindings.conf` — keybindings
- `autostart.conf` — programs to launch on login
- `windowrules.conf` — window-specific behavior
- `hypridle.conf`, `hyprlock.conf`, `hyprpaper.conf` — separate daemons

### Default apps
- **Terminal**: Ghostty (`build_files/etc/skel/.config/ghostty/config`)
- **File manager**: Yazi (terminal-based, launched in Ghostty via keybind)
- **Browser**: Neonwolf (AppImage-based, `/usr/bin/neonwolf`)
- **App store**: FlatArcade (Flathub TUI, launched in Ghostty)
- **Launcher**: Walker (with elephant plugins)
- **Bar**: Waybar
- **Notifications**: Mako

### /etc/skel caveat
Files under `build_files/etc/skel/` are copied to `/etc/skel/` during build, but **only apply to newly created users**. Changing a dotfile here does not update existing users' `~/.config`. For fast iteration, use `Dockerfile.overlay` and test with a fresh user account.

## Testing & Validation

There is **no unit-test suite**. Validation is:
1. `bootc container lint` (runs automatically at the end of both `Containerfile` and `Dockerfile.overlay`)
2. Booting the image in a VM (`just run-vm-qcow2`)
3. `just lint` — shellcheck on all `*.sh` files
4. `just format` — shfmt on all `*.sh` files

**VM builds require sudo**: `build-qcow2`, `build-iso`, `run-vm-*` need rootful Podman and KVM. The plain `just build` does not.

## CI & Release

- `.github/workflows/build.yml` builds and pushes to `ghcr.io/<owner>/hyprwave` on:
  - Push to `main`
  - Daily schedule (10:05 UTC)
  - Manual dispatch
- **PRs build but do not push or sign**
- Images are signed with Cosign (private key in `SIGNING_SECRET` repo secret, public key at `cosign.pub`)
- GitHub Action SHAs are pinned and updated by Renovate (`.github/renovate.json5`)
- The workflow **ignores README-only pushes** (`paths-ignore: '**/README.md'`)

## Common Tasks

### Add a new package
1. Edit the `dnf5 install` lists in `build_files/build.sh`
2. If from a COPR, enable it before install and disable after
3. Run `just build` to test
4. Run `just lint` and `just format` before committing

### Add a new dotfile/config
1. Create the file under `build_files/etc/skel/.config/`
2. For Hyprland: add a fragment and source it from the relevant parent config
3. Test with `podman build -f Dockerfile.overlay -t hyprwave:latest .`
4. Create a fresh test user to verify the dotfile is deployed

### Update a source-built hypr utility
1. Update the version tag in `build_files/build-hypr-utils.sh`
2. If there are build-time workarounds (like the Qt 6.11 WaylandClientPrivate patch), update those too
3. Run `just build` (full rebuild, not overlay)
4. Test in a VM to verify the utility works

### Change the base OS
Edit the `FROM` line in `Containerfile`. Other Universal Blue / Fedora / CentOS bootc bases are listed in comments. Test thoroughly — package availability and service names may differ.
