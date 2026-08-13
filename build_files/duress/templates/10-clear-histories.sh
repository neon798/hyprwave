#!/bin/sh
# Hyprwave MILD duress template — shell histories + clipboard only.
#
# Severity: MILD (vs aggressive 00-wipe-sensitive.sh).
# OPT-IN ONLY. NOT signed and NOT installed into ~/.duress or /etc/duress.d
# on a stock image. Copy + sign via:
#   hyprwave-duress-setup --mild-template
#   hyprwave-duress-setup --dry-run --mild-template   # preview only
#
# Does NOT delete SSH keys, browser profiles, or Documents.
# When run by pam_duress, PAMUSER is set (upstream).

set -eu

USER_NAME="${PAMUSER:-${USER:-}}"
if [ -z "$USER_NAME" ]; then
	USER_NAME="$(id -un 2>/dev/null || true)"
fi

USER_HOME=""
if [ -n "$USER_NAME" ]; then
	USER_HOME="$(getent passwd "$USER_NAME" 2>/dev/null | cut -d: -f6 || true)"
fi
if [ -z "$USER_HOME" ] || [ "$USER_HOME" = "/" ]; then
	USER_HOME="${HOME:-}"
fi
if [ -z "$USER_HOME" ] || [ "$USER_HOME" = "/" ]; then
	exit 0
fi

log() {
	printf '%s\n' "[hyprwave-duress-mild] $*" 2>/dev/null | \
		systemd-cat -t hyprwave-duress -p warning 2>/dev/null || true
}

log "clear-histories starting for user=${USER_NAME} home=${USER_HOME}"

# History / session breadcrumbs only.
FILES="
$USER_HOME/.bash_history
$USER_HOME/.zsh_history
$USER_HOME/.python_history
$USER_HOME/.local/share/fish/fish_history
$USER_HOME/.local/share/recently-used.xbel
$USER_HOME/.local/share/yazi/yazi.log
"

echo "$FILES" | while IFS= read -r path; do
	[ -n "$path" ] || continue
	[ -e "$path" ] || continue
	log "removing $path"
	shred -n 1 -z -- "$path" 2>/dev/null || rm -f -- "$path" 2>/dev/null || true
done

# Best-effort clipboard clear (Wayland / X11 if tools exist).
command -v wl-copy >/dev/null 2>&1 && printf '' | wl-copy 2>/dev/null || true
command -v wl-copy >/dev/null 2>&1 && printf '' | wl-copy --primary 2>/dev/null || true
command -v xclip >/dev/null 2>&1 && printf '' | xclip -selection clipboard 2>/dev/null || true
command -v xsel >/dev/null 2>&1 && xsel -bc 2>/dev/null || true

log "clear-histories finished for user=${USER_NAME}"
exit 0
