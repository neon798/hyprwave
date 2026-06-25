#!/bin/bash

set -ouex pipefail

### Enable required COPRs
dnf5 -y copr enable ashbuk/Hyprland-Fedora
dnf5 -y copr enable scottames/ghostty

### Install Hyprland and Wayland desktop stack
dnf5 install -y \
    hyprland \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    waybar \
    wofi \
    ghostty \
    mako \
    swaybg \
    grim \
    slurp \
    wl-clipboard \
    cliphist \
    brightnessctl \
    playerctl \
    pavucontrol \
    network-manager-applet \
    polkit-kde \
    blueman

### Install file-manager helpers + desktop utilities. The file manager is Yazi
### (a terminal app installed from upstream below — it isn't packaged in Fedora);
### these are its preview/extraction dependencies plus general desktop tools.
dnf5 install -y \
    ffmpegthumbnailer \
    poppler-utils \
    fd-find \
    unar \
    jq \
    ImageMagick \
    zoxide \
    gvfs \
    xarchiver \
    imv \
    mpv \
    geany

### Install login manager
dnf5 install -y \
    sddm

### Install useful CLI tools
dnf5 install -y \
    tmux \
    htop \
    fastfetch \
    git \
    curl \
    wget \
    unzip \
    fzf \
    ripgrep \
    bat \
    eza

### Install fonts (for proper icon rendering in Waybar, Wofi, etc.)
dnf5 install -y \
    google-noto-fonts-common \
    google-noto-sans-fonts \
    google-noto-serif-fonts \
    google-noto-emoji-fonts \
    jetbrains-mono-fonts \
    fontawesome-fonts \
    fira-code-fonts

### Disable COPRs so they don't end up enabled on the final image
dnf5 -y copr disable ashbuk/Hyprland-Fedora
dnf5 -y copr disable scottames/ghostty

### Install Yazi — Hyprwave's default file manager (terminal-based, latest release).
### Not packaged in Fedora, so we pull the upstream prebuilt binaries (yazi + the
### `ya` helper) from GitHub's /releases/latest/download/ redirect, same pattern as
### the apps below. Launched inside Ghostty from the keybind / .desktop.
curl -fsSL -o /tmp/yazi.zip \
    https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip
mkdir -p /tmp/yazi
unzip -q /tmp/yazi.zip -d /tmp/yazi
install -m0755 /tmp/yazi/*/yazi /usr/bin/yazi
install -m0755 /tmp/yazi/*/ya /usr/bin/ya
rm -rf /tmp/yazi /tmp/yazi.zip
cat >/usr/share/applications/yazi.desktop <<'EOF'
[Desktop Entry]
Name=Yazi
GenericName=File Manager
Comment=Blazing fast terminal file manager
Exec=ghostty -e yazi %f
Icon=system-file-manager
Type=Application
Categories=System;FileManager;Utility;
MimeType=inode/directory;
StartupNotify=true
Terminal=false
EOF

### Install Neonwolf — Hyprwave's default web browser (latest stable release).
### Built in its own repo (neon798/neonwolf) and shipped as an AppImage. We track
### the latest *stable* release via GitHub's /releases/latest/download/ redirect
### (excludes pre-releases, no API rate limits). The AppImage is extracted at build
### time so the deployed image needs no FUSE at runtime; /usr/bin/neonwolf launches it.
curl -fsSL -o /tmp/neonwolf.AppImage \
    https://github.com/neon798/neonwolf/releases/latest/download/Neonwolf-x86_64.AppImage
chmod +x /tmp/neonwolf.AppImage
(cd /tmp && ./neonwolf.AppImage --appimage-extract >/dev/null)
rm -rf /usr/lib/neonwolf
mv /tmp/squashfs-root /usr/lib/neonwolf
rm -f /tmp/neonwolf.AppImage
cat >/usr/bin/neonwolf <<'EOF'
#!/usr/bin/bash
exec /usr/lib/neonwolf/AppRun "$@"
EOF
chmod +x /usr/bin/neonwolf
cp -L /usr/lib/neonwolf/.DirIcon /usr/share/pixmaps/neonwolf.png 2>/dev/null || true
cat >/usr/share/applications/neonwolf.desktop <<'EOF'
[Desktop Entry]
Name=Neonwolf
GenericName=Web Browser
Comment=Synthwave, privacy-focused web browser
Exec=neonwolf %u
Icon=neonwolf
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=neonwolf
Terminal=false
EOF

### Install FlatArcade — Hyprwave's default "app store" (Flathub TUI, latest release).
### Also its own repo (neon798/flatarcade): a Rust/ratatui TUI for browsing Flathub
### and managing Flatpaks. Flatpak + the Flathub remote already come from the base
### image (at /etc/flatpak/remotes.d/flathub.flatpakrepo); no GUI store ships, so this
### TUI is the front-end. It's launched inside Ghostty from graphical launchers.
curl -fsSL -o /usr/bin/flatarcade \
    https://github.com/neon798/flatarcade/releases/latest/download/flatarcade
chmod +x /usr/bin/flatarcade
mkdir -p /usr/share/icons/hicolor/scalable/apps
curl -fsSL -o /usr/share/icons/hicolor/scalable/apps/flatarcade.svg \
    https://github.com/neon798/flatarcade/releases/latest/download/flatarcade.svg
cat >/usr/share/applications/flatarcade.desktop <<'EOF'
[Desktop Entry]
Name=FlatArcade
GenericName=Software Center
Comment=Browse Flathub and manage your Flatpaks
Exec=ghostty -e flatarcade
Icon=flatarcade
Type=Application
Categories=System;PackageManager;Settings;
StartupNotify=true
Terminal=false
EOF

### Enable system services
systemctl enable podman.socket
systemctl enable sddm.service
systemctl enable NetworkManager.service

### Set SDDM as the default display manager
ln -sf /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service

### Deploy default dotfiles to /etc/skel/ (new users get these on first login)
cp -r /ctx/etc/skel/. /etc/skel/

### Deploy wallpapers and system assets
mkdir -p /usr/share/hyprwave/wallpapers
cp -r /ctx/usr/share/hyprwave/wallpapers/* /usr/share/hyprwave/wallpapers/

