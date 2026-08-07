#!/usr/bin/env bash
# Generate full COSMIC Dark/Builder key trees for every Hyprwave theme pack.
# Output: build_files/usr/share/hyprwave/themes/<name>/cosmic/config/
# Run from repo root after `cargo build --release` in planning/bin/themegen.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
THEMEGEN="${ROOT}/planning/bin/themegen/target/release/themegen"
OUT_ROOT="${ROOT}/build_files/usr/share/hyprwave/themes"

if [[ ! -x "$THEMEGEN" ]]; then
	echo "Building themegen..."
	(cd "${ROOT}/planning/bin/themegen" && cargo build --release)
fi

# name|bg|accent|text|neutral|hint
# neutral defaults to a secondary accent; hint is window/active edge color
THEMES=(
	"hyprwave|15052e|ff2d95|e0e0ff|b967ff|00f0ff"
	"retro-arcade|0f0f23|00ff9f|e0e0ff|aa66ff|00ffff"
	"cozy-harvest|3a3228|ff9800|f5e8c7|8bc34a|4fc3f7"
	"fjord-dark|2e3440|5e81ac|eceff4|b48ead|88c0d0"
	"touge-drive|0c0c14|e63946|d8d8e8|7b2cbf|00b4d8"
	"vaporwave|2a1a3d|ff71ce|f0d0ff|b967ff|01cdfe"
	"highway-haze|0a0f1c|c97a9e|c8d4e8|5e6a8a|6fa8b8"
	"lunar-pulse|121a2e|7ec8d9|d4d8f0|a89ed6|9dd4e8"
	"glitch-horizon|08060c|a3ff3d|e8ffe0|ff3d9e|00f0ff"
	"arcade-rain|0a0e18|00e0ff|e8e0ff|ff4d9e|ffea5e"
	"verdant-haven|1f2a1f|2d5a27|e8e4d9|5c4033|5a8a7a"
)

for entry in "${THEMES[@]}"; do
	IFS='|' read -r name bg accent text neutral hint <<<"$entry"
	tmp=$(mktemp -d)
	echo "==> $name"
	"$THEMEGEN" \
		--name "$name" \
		--bg "$bg" \
		--accent "$accent" \
		--text "$text" \
		--neutral "$neutral" \
		--hint "$hint" \
		--out "$tmp"
	dest="${OUT_ROOT}/${name}/cosmic/config"
	rm -rf "$dest"
	mkdir -p "$dest"
	# themegen writes $out/cosmic/... — hoist into theme pack as config/
	if [[ -d "$tmp/cosmic" ]]; then
		cp -a "$tmp/cosmic/." "$dest/"
	else
		echo "ERROR: no cosmic/ under $tmp" >&2
		ls -laR "$tmp" >&2
		exit 1
	fi
	rm -rf "$tmp"
	echo "    wrote $dest ($(find "$dest" -type f | wc -l) files)"
done

echo "Done. All themes have cosmic/config/ vendor key trees."
