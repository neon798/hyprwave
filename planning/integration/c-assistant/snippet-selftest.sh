#!/usr/bin/env bash
# Fail-closed check: Containerfile.snippet + build.sh.snippet + HANDOFF
# still describe 0.2.2 assistant hooks. No live Containerfile/build.sh edits.
# Usage (from anywhere): bash planning/integration/c-assistant/snippet-selftest.sh
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CF="${DIR}/Containerfile.snippet"
BS="${DIR}/build.sh.snippet"
HO="${DIR}/HANDOFF.md"
VERSION="${ASSISTANT_VERSION:-0.2.2}"

die() { echo "snippet-selftest: FAIL: $*" >&2; exit 1; }
ok() { echo "snippet-selftest: OK: $*"; }

[[ -f "$CF" ]] || die "missing Containerfile.snippet"
[[ -f "$BS" ]] || die "missing build.sh.snippet"
[[ -f "$HO" ]] || die "missing HANDOFF.md"

# --- Containerfile.snippet: builder stage + stamped binary ---
grep -q 'AS assistant-builder' "$CF" \
  || die "Containerfile.snippet missing 'AS assistant-builder'"
grep -q "ASSISTANT_VERSION=${VERSION}" "$CF" \
  || die "Containerfile.snippet version drift (want ASSISTANT_VERSION=${VERSION})"
grep -q -- '-trimpath' "$CF" \
  || die "Containerfile.snippet missing -trimpath"
grep -q 'main.version' "$CF" \
  || die "Containerfile.snippet missing -X main.version ldflags"
grep -q 'COPY --from=assistant-builder' "$CF" \
  || die "Containerfile.snippet missing COPY --from=assistant-builder"
grep -q '/usr/bin/hyprwave-assistant' "$CF" \
  || die "Containerfile.snippet missing /usr/bin/hyprwave-assistant"
grep -q '/usr/share/hyprwave/assistant' "$CF" \
  || die "Containerfile.snippet missing data COPY path"

# --- build.sh.snippet: data + desktop + binary fallback ---
grep -q 'assistant-builder' "$BS" \
  || die "build.sh.snippet missing assistant-builder"
grep -q '/usr/bin/hyprwave-assistant' "$BS" \
  || die "build.sh.snippet missing /usr/bin/hyprwave-assistant"
grep -q '/usr/share/hyprwave/assistant' "$BS" \
  || die "build.sh.snippet missing /usr/share/hyprwave/assistant"
grep -q 'hyprwave-assistant.desktop' "$BS" \
  || die "build.sh.snippet missing hyprwave-assistant.desktop"

# --- HANDOFF: apply order + E/integrator-only keybind ---
grep -q "${VERSION}" "$HO" \
  || die "HANDOFF.md missing version ${VERSION}"
grep -q 'Containerfile.snippet' "$HO" \
  || die "HANDOFF.md must list Containerfile.snippet in apply order"
grep -q 'build.sh.snippet' "$HO" \
  || die "HANDOFF.md must list build.sh.snippet in apply order"
grep -q 'assistant-builder' "$HO" \
  || die "HANDOFF.md must mention assistant-builder"
grep -q '/usr/bin/hyprwave-assistant' "$HO" \
  || die "HANDOFF.md must mention /usr/bin/hyprwave-assistant"
if ! grep -qiE 'Super\+Shift\+A|SUPER SHIFT' "$HO"; then
  die "HANDOFF.md must mention Super+Shift+A"
fi
if ! grep -qiE 'Model E|integrator only|E / integrator' "$HO"; then
  die "HANDOFF.md must say Super+Shift+A is Model E / integrator only"
fi

# Never claim GHCR is public (lane-wide copy rule).
if grep -qiE 'ghcr is public|publicly available on ghcr' "$CF" "$BS" "$HO"; then
  die "snippets/HANDOFF must not claim GHCR is public"
fi

ok "hooks match ${VERSION} (assistant-builder, /usr/bin/hyprwave-assistant, apply order)"
exit 0
