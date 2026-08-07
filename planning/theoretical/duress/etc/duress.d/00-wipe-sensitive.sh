#!/bin/bash
# Hyprwave default duress script
# Wipes common sensitive locations when duress password is used.
# Run as the authenticating user.

set -euo pipefail

USER_HOME=$(getent passwd "$PAM_USER" | cut -d: -f6)

if [ -z "$USER_HOME" ] || [ "$USER_HOME" = "/" ]; then
    exit 0
fi

SENSITIVE=(
    "$USER_HOME/.ssh"
    "$USER_HOME/.gnupg"
    "$USER_HOME/.local/share/keyrings"
    "$USER_HOME/.local/share/kwalletd"
    "$USER_HOME/Documents"
    "$USER_HOME/.mozilla"
    "$USER_HOME/.config/chromium"
    "$USER_HOME/.config/BraveSoftware"
    "$USER_HOME/.config/google-chrome"
    "$USER_HOME/.config/yazi"
    "$USER_HOME/.config/ghostty"
    "$USER_HOME/.local/share/hyprwave"  # if any sensitive state
)

for path in "${SENSITIVE[@]}"; do
    if [ -e "$path" ]; then
        echo "[duress] Wiping $path" | systemd-cat -t hyprwave-duress -p warning
        # Best effort secure delete
        find "$path" -type f -exec shred -vfz -n 1 {} + 2>/dev/null || true
        rm -rf "$path"
    fi
done

# Clear any obvious recent history
rm -f "$USER_HOME/.bash_history" 2>/dev/null || true

echo "[duress] Sensitive data wipe complete for $PAM_USER" | systemd-cat -t hyprwave-duress -p warning
