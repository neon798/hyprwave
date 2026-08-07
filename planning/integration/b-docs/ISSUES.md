# Product / ops issues found while writing docs (Model B)

Docs lane does **not** fix product code. Record gaps here for stabilizer / integrator.

| ID | Severity | Issue | Notes |
|----|----------|--------|-------|
| B-1 | Ops | GHCR public pull not proven in this lane | INSTALL documents `ghcr.io/neon798/hyprwave:latest` and `-cosmic`; switch may fail if packages are private. Model A first-boot / pull checklist. |
| B-2 | Build | External apps still use `/releases/latest` | Yazi, Neonwolf, FlatArcade in `build_files/build.sh`. Reproducibility risk; owned by Model A pins. |
| B-3 | Docs/UX | README is developer-heavy | Long SDDM QML detail; weak top-level Hyprland install. Proposed fix in `README-sections.md` — not applied wholesale in wave 1. |
| B-4 | Product | First-boot “proven usable” still open | Code exists; E2E VM proof both DEs not done by docs lane. |
| B-5 | Product | Assistant / Duress not in image | Planning only; do not document as shipped. CHANGELOG marks them not present. |
| B-6 | Minor | Justfile default `IMAGE_NAME=image-template` | Local `just build` without override does not tag `hyprwave`. INSTALL calls this out; CI sets repo name. |

No blockers found that prevent shipping INSTALL/CHANGELOG language for the **current**
desktop design (Walker, hyprpaper, 11 themes, COSMIC, companions).
