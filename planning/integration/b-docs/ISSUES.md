# Product / ops issues (Model B)

Docs lane does **not** fix product code. Gaps for stabilizer / integrator.

| ID | Severity | Issue | Notes |
|----|----------|--------|-------|
| B-1 | Ops | GHCR still private (anonymous 403) | B-W3-001: INSTALL/first-boot treat **local build** as primary; Path A needs auth. A/RELEASE owns public visibility |
| B-2 | Build | External app pins | Owned by lane A (`versions.env`); docs point at philosophy only |
| B-3 | Docs/UX | README still long on SDDM QML | Wave 2 proposes sections in README-sections.md; partial install links applied |
| B-4 | Product | E2E first-boot both DEs | Still ops proof; not docs-blocked |
| B-5 | **Closed** (B-W2-001) | Assistant / Duress | **Assistant** is on `main` and image-hooked (`/usr/bin/hyprwave-assistant`, Super+Shift+A). **Duress** is packaged **off by default** — handbook never claims it is enabled. |
| B-6 | **Closed** (B-W2-002) | Justfile default `IMAGE_NAME=image-template` | Documented in INSTALL Path C + contributor-notes. Default remains `image-template`; override with `just build hyprwave latest` / `IMAGE_NAME=hyprwave`. CI uses repo name. **Justfile not edited** (docs-only). |
| B-7 | Docs | Screenshots | All TODO; checklist + alt-text ready in screenshot-checklist.md |

No docs blocker for describing current desktop design (Walker, hyprpaper, 11 themes,
COSMIC, companions).

## On main (Waves 2–4 / B-W6-001)

W2–W4 product + handbook deltas are **on `main`** (not lane-only merge-prep).
VM smoke and public GHCR are **not** closed.

| ID | State |
|----|--------|
| B-5 | Closed on main — Assistant on image + Super+Shift+A in handbook; duress **off by default** |
| B-6 | Closed on main — IMAGE_NAME=`image-template` documented; override in INSTALL |
| B-7 | **Open** — no screenshot binaries; checklist ready |
| B-1 | **Open** — GHCR anonymous 403; local build primary in INSTALL/first-boot |
| B-4 | **Open** — dual-variant E2E / **VM smoke** from the merged tip |

Do **not** flip B-1 closed until A/RELEASE confirms public packages.
Do **not** flip B-4 closed until VM smoke is signed off.
