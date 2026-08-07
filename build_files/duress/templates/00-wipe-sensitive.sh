#!/bin/sh
# Hyprwave default duress wipe template.
#
# OPT-IN ONLY. This file is NOT signed and NOT installed into ~/.duress or
# /etc/duress.d on a stock image. hyprwave-duress-setup copies + signs it after
# explicit user confirmation.
#
# When run by pam_duress:
#   - /etc/duress.d/* scripts run as root with PAMUSER set
#   - ~/.duress/* scripts run as the authenticating user with PAMUSER set
#
# DESTROYS DATA. Review TARGETS before signing. Test only in a disposable VM.

set -eu

# Prefer pam-duress PAMUSER; fall back for manual testing.
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

# Conservative common secret locations. Edit before signing if needed.
# Intentionally does NOT wipe the entire home directory.
TARGETS="
$USER_HOME/.ssh
$USER_HOME/.gnupg
$USER_HOME/.local/share/keyrings
$USER_HOME/.local/share/kwalletd
$USER_HOME/.mozilla
$USER_HOME/.librewolf
$USER_HOME/.neonwolf
$USER_HOME/.config/chromium
$USER_HOME/.config/BraveSoftware
$USER_HOME/.config/google-chrome
$USER_HOME/.cache/mozilla
$USER_HOME/.bash_history
$USER_HOME/.local/share/fish/fish_history
$USER_HOME/.zsh_history
"

log() {
	# Best-effort; never fail the wipe because logging failed.
	printf '%s\n' "[hyprwave-duress] $*" 2>/dev/null | \
		systemd-cat -t hyprwave-duress -p warning 2>/dev/null || true
}

log "wipe starting for user=${USER_NAME} home=${USER_HOME}"

echo "$TARGETS" | while IFS= read -r path; do
	# skip blanks
	[ -n "$path" ] || continue
	[ -e "$path" ] || continue
	log "wiping $path"
	if [ -d "$path" ]; then
		# Best-effort overwrite then remove. shred may be missing on minimal images.
		find "$path" -type f -exec shred -n 1 -z {} + 2>/dev/null || true
		rm -rf -- "$path" 2>/dev/null || true
	else
		shred -n 1 -z -- "$path" 2>/dev/null || rm -f -- "$path" 2>/dev/null || true
	fi
done

# Clear common clipboards if tools exist (best effort, non-fatal).
command -v wl-copy >/dev/null 2>&1 && printf '' | wl-copy 2>/dev/null || true
command -v xclip >/dev/null 2>&1 && printf '' | xclip -selection clipboard 2>/dev/null || true

log "wipe finished for user=${USER_NAME}"
exit 0
