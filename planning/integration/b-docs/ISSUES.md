# Product / ops issues (Model B)

Docs lane does **not** fix product code. Gaps for stabilizer / integrator.

| ID | Severity | Issue | Notes |
|----|----------|--------|-------|
| B-1 | Ops | GHCR may be private (403) | INSTALL + troubleshooting document this; A/RELEASE should fix visibility |
| B-2 | Build | External app pins | Owned by lane A (`versions.env`); docs point at philosophy only |
| B-3 | Docs/UX | README still long on SDDM QML | Wave 2 proposes sections in README-sections.md; partial install links applied |
| B-4 | Product | E2E first-boot both DEs | Still ops proof; not docs-blocked |
| B-5 | Product | Assistant / Duress | Document as upcoming / off-by-default only until merge |
| B-6 | Minor | Justfile default `IMAGE_NAME=image-template` | INSTALL notes; CI sets repo name |
| B-7 | Docs | Screenshots | All TODO; checklist + alt-text ready in screenshot-checklist.md |

No docs blocker for describing current desktop design (Walker, hyprpaper, 11 themes,
COSMIC, companions).
