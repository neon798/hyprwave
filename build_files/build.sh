#!/bin/bash

set -ouex pipefail

### Enable required COPRs
dnf5 -y copr enable solopasha/hyprland
dnf5 -y copr enable scottames/ghostty

### Install Hyprland and Wayland desktop stack
dnf5 install -y \
    hyprland \
    hyprlock \
    hypridle \
    hyprpaper \
    hyprpicker \
    hyprcursor \
    xdg-desktop-portal-hyprland \
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
    pamixer \
    pavucontrol \
    network-manager-applet \
    polkit-kde \
    qt5-qtwayland \
    qt6-qtwayland

### Install login manager
dnf5 install -y \
    sddm \
    sddm-wayland-generic

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

### Install fonts
dnf5 install -y \
    google-noto-fonts-common \
    google-noto-sans-fonts \
    google-noto-serif-fonts \
    google-noto-emoji-fonts \
    jetbrains-mono-fonts \
    fontawesome-fonts \
    fira-code-fonts

### Disable COPRs so they don't end up enabled on the final image
dnf5 -y copr disable solopasha/hyprland
dnf5 -y copr disable scottames/ghostty

### Enable system services
systemctl enable podman.socket
systemctl enable sddm.service
systemctl enable NetworkManager.service

### Set SDDM as the default display manager
ln -sf /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service

