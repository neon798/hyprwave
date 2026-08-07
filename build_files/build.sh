#!/bin/bash

set -ouex pipefail

### DE selects the desktop variant. Default to hyprland for backward compat.
### Valid values: hyprland (default, full current behavior), cosmic (COSMIC DE variant).
DE="${DE:-hyprland}"
case "$DE" in
hyprland | cosmic) ;;
*)
	echo "ERROR: DE must be 'hyprland' or 'cosmic' (got: $DE)" >&2
	exit 1
	;;
esac

### COPR mirrors can be flaky; make dnf retry harder before failing the whole build.
cat >>/etc/dnf/dnf.conf <<'EOF'
retries=25
minrate=100
timeout=120
max_parallel_downloads=4
EOF

### ---- shared (all variants) ----

### Ghostty terminal is shared across variants. Enable its COPR, install, then
### disable immediately so it does not leak. (The other COPRs are Hyprland-only
### and are handled inside the hyprland case.)
dnf5 -y copr enable scottames/ghostty

### Install ghostty (moved from the Hyprland-specific list so it is available for
### both desktops and for .desktop Exec lines that launch it for Yazi/FlatArcade).
dnf5 install -y ghostty

dnf5 -y copr disable scottames/ghostty

### Deploy wallpapers, theme store and system assets early (shared by both variants).
### Hyprland's SDDM theme references the default wallpaper; the theme store is used
### by hyprwave-theme on both Hyprland and COSMIC (cosmic/config key trees + wallpapers).
mkdir -p /usr/share/hyprwave
cp -r /ctx/usr/share/hyprwave/. /usr/share/hyprwave/
### Theme wallpapers must be world-readable (hyprpaper / cosmic-bg run as the user).
### Some generated JPGs land as 0600; force 0644 so theme switches can load them.
find /usr/share/hyprwave -type f \( -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o -name '*.webp' \) \
	-exec chmod 0644 {} +
find /usr/share/hyprwave -type d -exec chmod 0755 {} +

### Theme switcher — both DEs (detects Hyprland vs COSMIC at runtime).
### CLI: hyprwave-theme; beginner GUI: hyprwave-theme-gui (GTK4/libadwaita).
install -m0755 /ctx/usr/bin/hyprwave-theme /usr/bin/hyprwave-theme
install -m0755 /ctx/usr/bin/hyprwave-theme-gui /usr/bin/hyprwave-theme-gui
### Desktop entry for app library / dock ("Hyprwave Themes") — no terminal.
install -d /usr/share/applications
install -m0644 /ctx/usr/share/applications/hyprwave-theme.desktop /usr/share/applications/hyprwave-theme.desktop

### ---- desktop: ${DE} ----

case "$DE" in
hyprland)
	### Enable required COPRs
	### Hyprland itself comes from ashbuk/Hyprland-Fedora: it is the build that targets
	### Fedora 44. (solopasha/hyprland is more complete but its Hyprland/aquamarine need a
	### newer libdisplay-info soname than F44 ships, so it can't be installed here — we only
	### borrow its standalone *utilities* below, which link hyprutils, not aquamarine.)
	dnf5 -y copr enable ashbuk/Hyprland-Fedora
	dnf5 -y copr enable errornointernet/walker

	### Install Hyprland and Wayland desktop stack (Hyprland + lock/idle + portal from ashbuk)
	### ghostty is installed in the shared section above.
	dnf5 install -y \
		hyprland \
		xdg-desktop-portal-hyprland \
		xdg-desktop-portal-gtk \
		hyprlock \
		hypridle \
		waybar \
		walker \
		mako \
		grim \
		slurp \
		wl-clipboard \
		brightnessctl \
		playerctl \
		pavucontrol \
		network-manager-applet \
		polkit-kde \
		blueman

	### Runtime libraries for the source-built Hyprland utilities (hyprland-qtutils,
	### hyprpaper, hyprpicker, hyprsunset) that the hyprbuilder stage COPYs into the image.
	### These aren't packaged for F44 and the solopasha COPR is stale against current F44,
	### so they're compiled from upstream (see build-hypr-utils.sh / Containerfile). The
	### packages below are only the *runtime* deps; the -devel toolchain stays in the
	### throwaway builder stage.
	###   hyprland-qtutils -> Qt6 Quick stack            (the ANR/error GUI popups)
	###   hyprpaper        -> cairo/pango/glycin imaging  (wallpaper daemon)
	###   hyprpicker       -> cairo/pango                 (colour picker, Super+Shift+P)
	###   hyprsunset       -> hyprlang/hyprutils          (night-light, on demand)
	###   hyprshot         -> grim/slurp/jq (already installed) (screenshots, Super+S)
	dnf5 install -y \
		qt6-qtbase-gui \
		qt6-qtdeclarative \
		qt6-qtwayland \
		qt6-qtsvg \
		cairo \
		cairo-gobject \
		pango \
		pixman \
		librsvg2 \
		libwebp \
		libjpeg-turbo \
		file-libs \
		glycin-libs \
		glycin-loaders

	### Walker's provider backend: elephant. Walker 2.x has no built-in providers — the
	### app-launcher/calc/runner data all comes from elephant plugins, each shipped as its
	### own ~22 MB package. The `elephant` metapackage *Recommends* all ~18 of them (~500 MB);
	### install only the handful the launcher uses with weak deps disabled to keep it lean.
	dnf5 install -y --setopt=install_weak_deps=False \
		elephant \
		elephant-desktopapplications \
		elephant-calc \
		elephant-runner \
		elephant-menus \
		elephant-websearch \
		elephant-files \
		elephant-providerlist \
		elephant-clipboard \
		elephant-symbols
	rm -rf /usr/share/doc/elephant

	### Install login manager
	dnf5 install -y \
		sddm

	### Disable COPRs so they don't end up enabled on the final image
	### (solopasha was already disabled right after its utility install above)
	dnf5 -y copr disable ashbuk/Hyprland-Fedora
	dnf5 -y copr disable errornointernet/walker

	### Enable system services (Hyprland/SDDM specific)
	systemctl enable sddm.service

	### Set SDDM as the default display manager
	ln -sf /usr/lib/systemd/system/sddm.service /etc/systemd/system/display-manager.service

	### Deploy default dotfiles to /etc/skel/ (new users get these on first login)
	### Hyprland variant ships the full skel (hypr, walker, waybar, mako, autostart, etc.).
	cp -r /ctx/etc/skel/. /etc/skel/

	### Deploy the SDDM login theme (8-bit arcade synthwave QML) under /etc so the
	### pkexec helper can retint it at runtime (/usr is read-only under bootc).
	### Its background is the same wallpaper as the desktop, copied in next to the
	### theme so the login screen and desktop match. QtQuick/Controls/Layouts come
	### from qt6-qtdeclarative (already installed above for the hypr utilities).
	install -d /etc/sddm/themes
	cp -r /ctx/usr/share/sddm/themes/hyprwave /etc/sddm/themes/
	cp /usr/share/hyprwave/wallpapers/default.png /etc/sddm/themes/hyprwave/background.png
	mkdir -p /etc/sddm.conf.d
	cat >/etc/sddm.conf.d/10-hyprwave.conf <<'EOF'
[Theme]
Current=hyprwave
ThemeDir=/etc/sddm/themes
# Without an explicit cursor theme the greeter renders no cursor sprite (it shows
# up as an invisible pointer). Adwaita ships in the base image (/usr/share/icons).
CursorTheme=Adwaita
CursorSize=24
EOF

	### Root helper + polkit action so hyprwave-theme can retint the SDDM login
	### screen when the user switches packs (writes under /etc/sddm/themes/).
	install -d /usr/libexec /usr/share/polkit-1/actions
	install -m0755 /ctx/usr/libexec/hyprwave-sddm-theme /usr/libexec/hyprwave-sddm-theme
	install -m0644 /ctx/usr/share/polkit-1/actions/dev.hyprwave.sddm-theme.policy \
		/usr/share/polkit-1/actions/dev.hyprwave.sddm-theme.policy

	;;
cosmic)
	### COSMIC ships from official Fedora repos as a comps group (no COPR needed).
	### cosmic-greeter is the display manager (explicit because the group may not
	### always pull the greeter as a hard dep).
	dnf5 install -y @cosmic-desktop-environment cosmic-greeter

	### Enable cosmic-greeter and point the generic display-manager.service at it
	### (matches the SDDM pattern on the hyprland variant).
	systemctl enable cosmic-greeter.service
	ln -sf /usr/lib/systemd/system/cosmic-greeter.service /etc/systemd/system/display-manager.service

	### Declutter redundant COSMIC apps. Use --no-autoremove or dnf5 will
	### treat the rest of the comps group as unused and remove ~92 packages
	### (including cosmic-panel, cosmic-settings, the portal, etc.).
	### cosmic-term is kept because cosmic-session hard-requires it.
	### We replace: store with FlatArcade, edit with geany, player with mpv,
	### wallpapers with our hyprwave wallpaper.
	dnf5 remove -y --no-autoremove cosmic-store cosmic-edit cosmic-player cosmic-wallpapers

	### Deploy Hyprwave vendor-default cosmic-config layer (dock favorites,
	### background, and the generated synthwave theme trees). These override Fedora's
	### cosmic-config-fedora defaults under /usr/share/cosmic/ and apply to every
	### user (user ~/.config/cosmic still wins). Must run *after* the RPMs have
	### laid down their files.
	mkdir -p /usr/share/backgrounds/hyprwave
	cp /usr/share/hyprwave/wallpapers/default.png /usr/share/backgrounds/hyprwave/default.png
	cp -r /ctx/usr/share/cosmic/. /usr/share/cosmic/

	### Skel subset for COSMIC: ghostty + yazi + theme indirection.
	### COSMIC provides its own launcher/panel/notifications — no hypr/walker/waybar/mako.
	### Ghostty colors + hyprwave-theme (COSMIC mode) share ~/.config/hyprwave/theme.
	### Vendor defaults under /usr/share/cosmic/ remain the first-boot synthwave; after that
	### `hyprwave-theme set` writes user overrides into ~/.config/cosmic/.
	mkdir -p /etc/skel/.config/hyprwave
	ln -sfn /usr/share/hyprwave/themes/hyprwave /etc/skel/.config/hyprwave/theme
	cp -r /ctx/etc/skel/.config/ghostty /etc/skel/.config/ 2>/dev/null || true
	cp -r /ctx/etc/skel/.config/yazi /etc/skel/.config/ 2>/dev/null || true
	;;
esac

### ---- shared (all variants) ----

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
	imv \
	mpv \
	geany

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

### Remove stock Firefox (pulled in by the base image). Neonwolf is the default
### browser; firefox-langpacks depends on firefox so both go together.
dnf5 remove -y firefox firefox-langpacks

### Remove xterm (pulled in transitively); Ghostty is the only terminal we ship.
### Guarded so the build doesn't fail if a future base stops shipping it.
rpm -q xterm &>/dev/null && dnf5 remove -y xterm || true

### Pinned external companion apps (Yazi / Neonwolf / FlatArcade).
### Versions + sha256 live in /ctx/versions.env (build_files/versions.env).
### See planning/integration/a-stabilize/BUMP.md for how to bump pins.
# shellcheck source=/dev/null
. /ctx/versions.env

### curl dest, then fail the build if sha256 does not match the pin.
verify_sha256() {
	local file="$1"
	local expected="$2"
	echo "${expected}  ${file}" | sha256sum -c -
}

### Install Yazi — Hyprwave's default file manager (terminal-based, pinned release).
### Not packaged in Fedora, so we pull the upstream prebuilt binaries (yazi + the
### `ya` helper) from a versioned GitHub release URL. Launched inside Ghostty.
curl -fsSL -o /tmp/yazi.zip "${YAZI_URL}"
verify_sha256 /tmp/yazi.zip "${YAZI_SHA256}"
mkdir -p /tmp/yazi
unzip -q /tmp/yazi.zip -d /tmp/yazi
install -m0755 /tmp/yazi/*/yazi /usr/bin/yazi
install -m0755 /tmp/yazi/*/ya /usr/bin/ya
rm -rf /tmp/yazi /tmp/yazi.zip
cat >/usr/share/applications/yazi.desktop <<'EOF'
[Desktop Entry]
Name=Yazi
GenericName=Files
Comment=Blazing fast terminal file manager
Keywords=files;file manager;explorer;
Exec=ghostty -e yazi %f
Icon=system-file-manager
Type=Application
Categories=System;FileManager;Utility;
MimeType=inode/directory;
StartupNotify=true
Terminal=false
EOF

### Install Neonwolf — Hyprwave's default web browser (pinned AppImage release).
### Built in its own repo (neon798/neonwolf). The AppImage is extracted at build
### time so the deployed image needs no FUSE at runtime; /usr/bin/neonwolf launches it.
curl -fsSL -o /tmp/neonwolf.AppImage "${NEONWOLF_URL}"
verify_sha256 /tmp/neonwolf.AppImage "${NEONWOLF_SHA256}"
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

### Install FlatArcade — Hyprwave's default "app store" (Flathub TUI, pinned release).
### Also its own repo (neon798/flatarcade): a Rust/ratatui TUI for browsing Flathub
### and managing Flatpaks. Flatpak + the Flathub remote already come from the base
### image (at /etc/flatpak/remotes.d/flathub.flatpakrepo); no GUI store ships, so this
### TUI is the front-end. It's launched inside Ghostty from graphical launchers.
curl -fsSL -o /usr/bin/flatarcade "${FLATARCADE_URL}"
verify_sha256 /usr/bin/flatarcade "${FLATARCADE_SHA256}"
chmod +x /usr/bin/flatarcade
mkdir -p /usr/share/icons/hicolor/scalable/apps
curl -fsSL -o /usr/share/icons/hicolor/scalable/apps/flatarcade.svg "${FLATARCADE_SVG_URL}"
verify_sha256 /usr/share/icons/hicolor/scalable/apps/flatarcade.svg "${FLATARCADE_SVG_SHA256}"
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

### Refresh the hicolor icon cache so GTK launchers (Walker) pick up the icons we
### just added (flatarcade.svg). The base image ships a prebuilt icon-theme.cache;
### without regenerating it, GTK reads the stale cache and the new icon is missing.
gtk-update-icon-cache -f /usr/share/icons/hicolor || true

### Enable system services
systemctl enable podman.socket
systemctl enable NetworkManager.service
