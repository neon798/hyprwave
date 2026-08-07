#!/bin/bash
#
# Builds the Hyprland utility ecosystem from upstream source.
#
# Runs in a dedicated builder stage (see Containerfile) — NOT in the final image —
# so the heavy -devel toolchain never ships. Components destined for the final image
# are staged into $DESTROOT (=/install); the Containerfile COPYs that tree into the
# runtime image. Pure build-time pieces (hyprwayland-scanner, hyprland-protocols) are
# installed only into the builder's /usr so later components can find them.
#
# Why source-built: on Fedora 44 these tools aren't in Fedora's repos; the ashbuk COPR
# ships only the compositor, and solopasha's COPR is stale (Qt 6.10 / libdisplay-info
# 0.2) and conflicts with current F44 (Qt 6.11 / libdisplay-info 0.3). See build.sh.

set -ouex pipefail

DESTROOT=/install
JOBS="$(nproc)"

### Build-time deps (only in this throwaway stage)
dnf5 install -y \
    gcc-c++ cmake ninja-build meson pkgconf-pkg-config git \
    wayland-devel wayland-protocols-devel libxkbcommon-devel pixman-devel \
    cairo-devel pango-devel mesa-libGL-devel mesa-libEGL-devel libdrm-devel \
    libjpeg-turbo-devel libwebp-devel file-devel pugixml-devel libzip-devel \
    librsvg2-devel tomlplusplus-devel glycin-devel \
    qt6-qtbase-devel qt6-qtbase-private-devel qt6-qtdeclarative-devel \
    qt6-qtdeclarative-private-devel qt6-qtwayland-devel

# cmake_build <repo> <tag> <stage?> [extra cmake args...]
#   stage=yes  -> also install into $DESTROOT for the final image
#   stage=no   -> install only into the builder /usr (build-time-only dependency)
cmake_build() {
    local repo="$1" tag="$2" stage="$3"
    shift 3
    local name="${repo##*/}"
    cd /tmp
    rm -rf "$name"
    git clone --depth 1 -b "$tag" "https://github.com/$repo" "$name"
    cd "$name"
    cmake -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release "$@"
    cmake --build build -j"$JOBS"
    cmake --install build
    [ "$stage" = yes ] && DESTDIR="$DESTROOT" cmake --install build
    ldconfig
}

### Core libraries (runtime deps of the tools -> staged for the final image)
cmake_build hyprwm/hyprutils    v0.13.1 yes
cmake_build hyprwm/hyprlang     v0.6.8  yes
cmake_build hyprwm/hyprgraphics v0.5.1  yes

### Build-time-only helpers (not shipped)
cmake_build hyprwm/hyprwayland-scanner v0.4.6 no
cd /tmp && rm -rf hyprland-protocols
git clone --depth 1 -b v0.7.0 https://github.com/hyprwm/hyprland-protocols
(cd hyprland-protocols && meson setup build --prefix=/usr && meson install -C build)

### hyprland-qt-support: QML style + lib used by qtutils (staged)
cmake_build hyprwm/hyprland-qt-support v0.1.0 yes

### hyprland-qtutils: provides hyprland-dialog (the ANR/error popup Hyprland spawns;
### its absence is what triggers "system does not have hyprland-qtutils installed").
### Qt 6.11 no longer auto-exposes Qt6::WaylandClientPrivate from the public WaylandClient
### component, so add it as an explicit find_package component (qt6-qtbase-private-devel
### supplies the backing private modules).
cd /tmp && rm -rf hyprland-qtutils
git clone --depth 1 -b v0.1.5 https://github.com/hyprwm/hyprland-qtutils
cd hyprland-qtutils
sed -i 's/COMPONENTS Widgets Quick QuickControls2 WaylandClient)/COMPONENTS Widgets Quick QuickControls2 WaylandClient WaylandClientPrivate)/' \
    CMakeLists.txt utils/dialog/CMakeLists.txt utils/update-screen/CMakeLists.txt utils/donate-screen/CMakeLists.txt
cmake -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
cmake --build build -j"$JOBS"
DESTDIR="$DESTROOT" cmake --install build

### Standalone tools (staged)
cmake_build hyprwm/hyprpicker v0.4.7 yes
cmake_build hyprwm/hyprsunset v0.3.3 yes
### hyprpaper 0.7.6 (cairo/pango/hyprgraphics); 0.8.x needs the newer hyprtoolkit chain.
cmake_build hyprwm/hyprpaper  v0.7.6 yes

### hyprshot is a single POSIX shell script (needs grim/slurp/jq at runtime)
install -Dm0755 /dev/stdin "$DESTROOT/usr/bin/hyprshot" < <(
    curl -fsSL https://raw.githubusercontent.com/Gustash/hyprshot/1.3.0/hyprshot
)
