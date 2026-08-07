# Endpoint — what “finished” means

The Task Master program ends when **all** of the following are true (or explicitly deferred with a tracked residual).

## Product

1. **Integrated main** contains Wave 1+2 lanes (stabilize, docs, assistant, duress assets) without losing pins or docs.
2. **Hyprland image** builds (`just build`) with pinned external binaries (no `/releases/latest`).
3. **COSMIC image** builds (`just build-cosmic`) with Hyprwave vendor defaults intact.
4. **Assistant** is built into the image (or clearly gated) and launches; KB + catalog usable offline.
5. **Duress** remains **packaged, OFF by default**; ENABLE.md complete; `validate.sh` green; no pre-signed scripts.
6. **Desktop** (Hyprland skel): coherent bindings, autostart, Walker/waybar/mako/hyprpaper, documented keybinds match reality.
7. **COSMIC** greeter/session defaults feel on-brand; FlatArcade remains app store; no COSMIC store regression.
8. **Docs**: INSTALL, CHANGELOG, troubleshooting, architecture, keybinds; accurate vs shipped tree.
9. **QA**: automated packaging checks (pins, theme consistency, duress validate, assistant `go test`) documented and runnable.
10. **Release path**: GHCR visibility/publish notes, first-boot checklist with log template, no silent `:latest` downloads.

## Process

- Lanes A–G have clear ownership; residual work is either DONE or listed in `STATUS.md` Residuals.
- Director has closed final wave with `status: PROGRAM_COMPLETE` in `STATUS.md`.

## Non-goals (unless a later program says so)

- Enabling duress PAM in default images.
- Full NVIDIA hardware certification farm.
- Rewriting the theme pack from scratch.
- Marketing website deployment.
