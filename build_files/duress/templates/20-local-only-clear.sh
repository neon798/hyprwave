#!/bin/sh
# Hyprwave MILD duress template — local browser session caches only.
#
# Severity: MILD (between 10-clear-histories and aggressive 00-wipe-sensitive).
# OPT-IN ONLY. NOT signed and NOT installed into ~/.duress or /etc/duress.d
# on a stock image. Copy + sign via:
#   hyprwave-duress-setup --local-clear-template
#   hyprwave-duress-setup --dry-run --local-clear-template   # preview only
#
# Scope: clears browser *session cache* trees under a single cache root
# ($USER_HOME/.cache). Does NOT delete:
#   - full browser profiles (~/.mozilla, ~/.config/chromium, …)
#   - SSH/GPG keys, keyrings, Documents
#   - passwords stored in profile DBs (those live outside this root)
#
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

# Single path root: only session caches under ~/.cache (local-only).
CACHE_ROOT="$USER_HOME/.cache"

log() {
	printf '%s\n' "[hyprwave-duress-local-clear] $*" 2>/dev/null | \
		systemd-cat -t hyprwave-duress -p warning 2>/dev/null || true
}

log "local-only-clear starting for user=${USER_NAME} cache_root=${CACHE_ROOT}"

# Hard guard: refuse to operate if CACHE_ROOT is not under home.
case "$CACHE_ROOT" in
"$USER_HOME"/.cache) ;;
*)
	log "refusing unexpected CACHE_ROOT=$CACHE_ROOT"
	exit 0
	;;
esac

if [ ! -d "$CACHE_ROOT" ]; then
	log "no cache root; nothing to do"
	exit 0
fi

# Session / code caches only — not full profiles under ~/.mozilla or ~/.config.
TARGETS="
$CACHE_ROOT/mozilla
$CACHE_ROOT/thumbnails
$CACHE_ROOT/mesa_shader_cache
$CACHE_ROOT/chromium
$CACHE_ROOT/google-chrome
$CACHE_ROOT/BraveSoftware
$CACHE_ROOT/neonwolf
$CACHE_ROOT/librewolf
$CACHE_ROOT/ms-playwright
$CACHE_ROOT/pip
"

echo "$TARGETS" | while IFS= read -r path; do
	[ -n "$path" ] || continue
	# Must remain under CACHE_ROOT (path traversal guard).
	case "$path" in
	"$CACHE_ROOT"/*) ;;
	*)
		log "skip path outside cache root: $path"
		continue
		;;
	esac
	[ -e "$path" ] || continue
	log "clearing $path"
	if [ -d "$path" ]; then
		rm -rf -- "$path" 2>/dev/null || true
	else
		rm -f -- "$path" 2>/dev/null || true
	fi
done

log "local-only-clear finished for user=${USER_NAME}"
exit 0
