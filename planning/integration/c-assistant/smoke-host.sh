#!/usr/bin/env bash
# Hyprwave Assistant — pre-merge / integrator host smoke (no image required).
# Exit 0 only if tests, build, and read-only CLI probes succeed.
# Usage (from repo root): bash planning/integration/c-assistant/smoke-host.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
APP="${ROOT}/apps/hyprwave-assistant"
DATA="${ROOT}/build_files/usr/share/hyprwave/assistant"
BIN="${SMOKE_BIN:-/tmp/hyprwave-assistant-smoke}"
VERSION="${ASSISTANT_VERSION:-0.2.2}"

die() { echo "smoke-host: FAIL: $*" >&2; exit 1; }
ok()  { echo "smoke-host: OK: $*"; }

# head can SIGPIPE under pipefail; absorb for display-only probes
probe_head() {
  local n="$1"; shift
  set +o pipefail
  "$@" | head -n "$n" || true
  set -o pipefail
}

[[ -d "$APP" ]] || die "missing $APP"
[[ -d "$DATA" ]] || die "missing data dir $DATA"
[[ -f "$DATA/catalog.toml" ]] || die "missing catalog.toml"
[[ -d "$DATA/kb" ]] || die "missing kb/"
shopt -s nullglob
kb_files=("$DATA"/kb/*.md)
(( ${#kb_files[@]} > 0 )) || die "no kb/*.md files"
[[ -f "${ROOT}/build_files/usr/share/applications/hyprwave-assistant.desktop" ]] \
  || die "missing hyprwave-assistant.desktop"

command -v go >/dev/null || die "go not in PATH"

cd "$APP"
ok "go test ./... (cwd=$APP)"
go test ./...

ok "go build -trimpath -ldflags version=${VERSION}"
CGO_ENABLED=0 go build -trimpath \
  -ldflags="-s -w -X main.version=${VERSION}" \
  -o "$BIN" .

[[ -x "$BIN" ]] || die "binary not executable: $BIN"

export HYPRWAVE_ASSISTANT_DATA="$DATA"

ok "$BIN --help"
"$BIN" --help >/dev/null

ok "$BIN --version"
ver_out="$("$BIN" --version)"
echo "  $ver_out"
[[ "$ver_out" == *"${VERSION}"* ]] || die "version output expected ${VERSION}, got: $ver_out"

ok "$BIN kb (list)"
probe_head 8 "$BIN" kb

ok "$BIN list"
probe_head 8 "$BIN" list

ok "$BIN update --dry-run"
probe_head 20 "$BIN" update --dry-run

# Day-1 accuracy guards (C-W2-001)
[[ -f "$DATA/kb/ghcr.md" ]] || die "missing kb/ghcr.md"
[[ -f "$DATA/kb/first-boot.md" ]] || die "missing kb/first-boot.md"
[[ -f "$DATA/kb/variants.md" ]] || die "missing kb/variants.md"
# Every wofi/swaybg mention must be a clear denial (not the default stack)
while IFS= read -r line; do
  echo "$line" | grep -qiE 'not[[:space:]]|never[[:space:]]|is not used' \
    || die "kb mentions wofi/swaybg without denial: $line"
done < <(grep -RniE '\bwofi\b|\bswaybg\b' "$DATA/kb" --include='*.md' || true)
grep -qiE 'Super\+Shift\+A|Super \+ Shift \+ A' "$DATA/kb/keybindings.md" \
  || die "keybindings.md must document Super+Shift+A"
grep -qiE 'off by default|OFF by default|OFF in the stock' "$DATA/kb/duress.md" \
  || die "duress.md must state off by default / stock image"
grep -qiE '\b11\b|eleven' "$DATA/kb/theming.md" \
  || die "theming.md must state 11 themes"
grep -qiE 'may be private' "$DATA/kb/ghcr.md" \
  || die "ghcr.md must state GHCR may be private"
grep -q 'com.discordapp.Discord' "$DATA/catalog.toml" \
  || die "catalog missing verified Discord Flatpak ID"
grep -q 'org.mozilla.Thunderbird' "$DATA/catalog.toml" \
  || die "catalog missing verified Thunderbird Flatpak ID"
grep -q 'com.spotify.Client' "$DATA/catalog.toml" \
  || die "catalog missing verified Spotify Flatpak ID"

ok "all probes passed (version=${VERSION}, data=${DATA}, kb day-1 guards)"
exit 0
