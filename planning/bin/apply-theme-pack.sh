#!/usr/bin/env bash
# Hyprwave Additional Themes + Duress Password Pack - Apply Script
#
# SINGLE COMMAND READY (after Claude verification)
#
# Usage after approval:
#   ./planning/bin/apply-theme-pack.sh --apply
#
# This script will:
#   1. Copy theme definitions into build_files/etc/skel/.config/
#   2. Install Walker themes
#   3. Add COSMIC .ron themes
#   4. Update SDDM theme support (multiple confs)
#   5. Patch build.sh to support THEME selection and install all themes
#   6. Add a simple theme switcher script to /usr/bin/
#   7. Handle both hyprland and cosmic variants
#   8. (when --duress) Deploy PAM Duress module, default scripts, and setup tool
#
# SAFETY: This script is currently in PLANNING mode.
# It will refuse to run without --force or specific env unless you edit it.
#
# Run with --dry-run first.
#
# Core spirit preserved: all themes have retro/neon/cozy/driving/anime/vapor vibes.
# Duress support is optional and privacy-focused.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLANNING_THEMES="$REPO_ROOT/planning/themes"

DRY_RUN=true
APPLY=false

for arg in "$@"; do
    case "$arg" in
        --apply) APPLY=true; DRY_RUN=false ;;
        --dry-run) DRY_RUN=true ;;
        --force) FORCE=true ;;
    esac
done

echo "=== Hyprwave Theme Pack Applicator (THEORETICAL / PLANNING) ==="
echo "Repo root: $REPO_ROOT"
echo "Themes source: $PLANNING_THEMES"
echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY-RUN (no changes)" || echo "APPLY MODE")"

if [ "$DRY_RUN" = false ] && [ "${FORCE:-false}" != "true" ]; then
    echo "ERROR: This is a planning script."
    echo "Claude must verify and you must pass --force after handoff."
    echo "See planning/ADDITIONAL-THEMES.md and previous COSMIC planning."
    exit 1
fi

THEMES=("retro-arcade" "cozy-harvest" "fjord-dark" "touge-drive" "vaporwave" "highway-haze" "lunar-pulse" "glitch-horizon" "arcade-rain" "verdant-haven")

do_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo "  [DRY] $*"
    else
        echo "  [RUN] $*"
        eval "$@"
    fi
}

echo ""
echo "=== Step 1: Ensure theme directories in build_files ==="

# For Hyprland skel - we will add a themes/ dir under .config for easy switching
do_cmd mkdir -p "$REPO_ROOT/build_files/etc/skel/.config/hypr/themes"
do_cmd mkdir -p "$REPO_ROOT/build_files/etc/skel/.config/walker/themes"
do_cmd mkdir -p "$REPO_ROOT/build_files/etc/skel/.config/waybar/themes"
do_cmd mkdir -p "$REPO_ROOT/build_files/etc/skel/.config/ghostty/themes"
do_cmd mkdir -p "$REPO_ROOT/build_files/etc/skel/.config/mako/themes"
do_cmd mkdir -p "$REPO_ROOT/build_files/usr/share/hyprwave/themes"

# COSMIC themes
do_cmd mkdir -p "$REPO_ROOT/build_files/usr/share/cosmic/cosmic-themes"

echo ""
echo "=== Step 2: Install per-theme files ==="

for theme in "${THEMES[@]}"; do
    echo "Processing theme: $theme"

    SRC="$PLANNING_THEMES/$theme"

    # Hypr looknfeel
    if [ -f "$SRC/hypr/looknfeel.conf" ]; then
        do_cmd cp "$SRC/hypr/looknfeel.conf" "$REPO_ROOT/build_files/etc/skel/.config/hypr/themes/looknfeel-$theme.conf"
    fi

    # Ghostty
    if [ -f "$SRC/ghostty/config" ]; then
        do_cmd cp "$SRC/ghostty/config" "$REPO_ROOT/build_files/etc/skel/.config/ghostty/themes/$theme.conf"
    fi

    # Waybar
    if [ -f "$SRC/waybar/style.css" ]; then
        do_cmd cp "$SRC/waybar/style.css" "$REPO_ROOT/build_files/etc/skel/.config/waybar/themes/$theme.css"
    fi

    # Walker - create theme dir
    do_cmd mkdir -p "$REPO_ROOT/build_files/etc/skel/.config/walker/themes/$theme"
    if [ -f "$SRC/walker/style.css" ]; then
        do_cmd cp "$SRC/walker/style.css" "$REPO_ROOT/build_files/etc/skel/.config/walker/themes/$theme/style.css"
    fi
    # Copy layout if present, else note to use main hyprwave layout
    if [ -f "$SRC/walker/layout.xml" ]; then
        do_cmd cp "$SRC/walker/layout.xml" "$REPO_ROOT/build_files/etc/skel/.config/walker/themes/$theme/layout.xml"
    fi

    # Mako
    if [ -f "$SRC/mako/config" ]; then
        do_cmd cp "$SRC/mako/config" "$REPO_ROOT/build_files/etc/skel/.config/mako/themes/$theme"
    fi

    # COSMIC
    if [ -f "$SRC/cosmic/$theme.ron" ]; then
        do_cmd mkdir -p "$REPO_ROOT/build_files/usr/share/cosmic/cosmic-themes/$theme"
        do_cmd cp "$SRC/cosmic/$theme.ron" "$REPO_ROOT/build_files/usr/share/cosmic/cosmic-themes/$theme/theme.ron"
    fi

    # SDDM
    if [ -f "$SRC/sddm/theme.conf" ]; then
        do_cmd mkdir -p "$REPO_ROOT/build_files/usr/share/sddm/themes/hyprwave-$theme"
        # For now, we will use the same Main.qml from original hyprwave and override conf
        # In real apply we would cp or symlink the QML + the theme.conf
        do_cmd cp "$SRC/sddm/theme.conf" "$REPO_ROOT/build_files/usr/share/sddm/themes/hyprwave-$theme/theme.conf"
    fi

    # Wallpaper note
    echo "  (Wallpaper for $theme should be added to build_files/usr/share/hyprwave/wallpapers/ or referenced)"
done

echo ""
echo "=== Step 3: Copy original hyprwave as default (if not already) ==="
# Assume the current files stay as "hyprwave" default.

echo ""
echo "=== Step 4: (Simulated) Update build.sh to support theme pack ==="
echo "  In real run, this would append to the cosmic and hyprland cases:"
echo "    - Copy all walker themes"
echo "    - Deploy cosmic themes"
echo "    - Deploy SDDM theme variants"
echo "    - Install a /usr/bin/hyprwave-set-theme script"
echo "    - Set default theme (hyprwave for both, or per-variant)"

# The actual patching would be done with sed or heredoc in the real script.
# For now we leave the source files ready.

echo ""
echo "=== Step 5: Install theme switcher script (theoretical) ==="
do_cmd mkdir -p "$REPO_ROOT/build_files/usr/bin"
# We would write the switcher script here.

cat > /tmp/hyprwave-set-theme.sh << 'SWITCHER'
#!/usr/bin/env bash
# hyprwave-set-theme <theme-name>
# Switches active theme for current user (Hyprland + supporting apps)
# To be installed by build.sh
set -e
THEME=${1:-hyprwave}
CONFIG_DIR="$HOME/.config"

# Hypr
if [ -f "$CONFIG_DIR/hypr/themes/looknfeel-$THEME.conf" ]; then
    ln -sf "$CONFIG_DIR/hypr/themes/looknfeel-$THEME.conf" "$CONFIG_DIR/hypr/looknfeel.conf"
    hyprctl reload || true
fi

# Ghostty - user can source or use --config
echo "Ghostty: use ghostty --config=~/.config/ghostty/themes/$THEME.conf or update your config"

# Waybar - restart with new style
if [ -f "$CONFIG_DIR/waybar/themes/$THEME.css" ]; then
    ln -sf "$CONFIG_DIR/waybar/themes/$THEME.css" "$CONFIG_DIR/waybar/style.css"
    pkill waybar; waybar &
fi

# Walker theme (edit config.toml theme = "...")
# Mako etc.

echo "Theme '$THEME' activated (some apps may need restart)"
SWITCHER

do_cmd cp /tmp/hyprwave-set-theme.sh "$REPO_ROOT/build_files/usr/bin/hyprwave-set-theme" || true
do_cmd chmod +x "$REPO_ROOT/build_files/usr/bin/hyprwave-set-theme" || true

echo ""
echo "=== Step 6: Duress password support (theoretical, --duress flag) ==="
if [[ "$*" == *--duress* ]]; then
    echo "  Deploying PAM Duress theoretical files..."
    do_cmd mkdir -p "$REPO_ROOT/build_files/etc/pam.d"
    do_cmd mkdir -p "$REPO_ROOT/build_files/etc/duress.d"
    do_cmd mkdir -p "$REPO_ROOT/build_files/usr/local/bin"

    # Copy theoretical pam stacks (user would merge carefully)
    # In real: patch the existing pam files or use drop-ins
    do_cmd cp "$REPO_ROOT/planning/theoretical/duress/etc/pam.d/sddm" "$REPO_ROOT/build_files/etc/pam.d/sddm" || true
    do_cmd cp "$REPO_ROOT/planning/theoretical/duress/etc/pam.d/greetd" "$REPO_ROOT/build_files/etc/pam.d/greetd" || true

    do_cmd cp "$REPO_ROOT/planning/theoretical/duress/etc/duress.d/00-wipe-sensitive.sh" "$REPO_ROOT/build_files/etc/duress.d/" || true
    do_cmd chmod +x "$REPO_ROOT/build_files/etc/duress.d/00-wipe-sensitive.sh" || true

    do_cmd cp "$REPO_ROOT/planning/theoretical/duress/usr/local/bin/hyprwave-duress-setup" "$REPO_ROOT/build_files/usr/local/bin/" || true
    do_cmd chmod +x "$REPO_ROOT/build_files/usr/local/bin/hyprwave-duress-setup" || true

    echo "  (In real build.sh: also compile pam-duress.so in builder stage and install to /lib64/security)"
fi

echo ""
echo "=== Step 7: Hyprwave Assistant (theoretical) ==="
echo "  In a real build this would:"
echo "    - Build or copy the hyprwave-assistant Rust binary (ratatui)"
echo "    - Deploy catalog, KB articles, and desktop entry"
echo "    - Make 'hyprwave-assistant' (or 'hyprwave') command available"
echo "  Source is in planning/theoretical/hyprwave-assistant/"
# do_cmd cargo build --release --manifest-path "$REPO_ROOT/planning/theoretical/hyprwave-assistant/Cargo.toml" || true
# do_cmd cp target/release/hyprwave-assistant /usr/bin/hyprwave-assistant
# do_cmd cp -r planning/theoretical/hyprwave-assistant/kb "$REPO_ROOT/build_files/usr/share/hyprwave/assistant/"
# do_cmd cp planning/theoretical/hyprwave-assistant/catalog.toml "$REPO_ROOT/build_files/usr/share/hyprwave/assistant/"

echo ""
echo "=== Done (theoretical) ==="
echo "Run with --apply --force ONLY after full Claude verification and handoff."
echo "All source material is in planning/themes/<theme>/ and planning/theoretical/duress/"
echo ""
echo "Suggested next: Claude reviews, then one command applies everything cleanly."
