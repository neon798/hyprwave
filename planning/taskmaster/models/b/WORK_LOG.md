# Model B Work Log

(append only)


## 2026-08-13 — B-W5-001

- status OPEN → IN_PROGRESS → DONE
- Merged origin/main (B W2–4 handbook already on main)
- Link walk checked=150 missing=0
- Super+Shift+A + Assistant companions confirmed in keybinds.md + README
- No GHCR-public claim; duress off-by-default intact
- ACCURACY-AUDIT B-W5-001 addendum


## 2026-08-13 — B-W4-001

- status OPEN → IN_PROGRESS → DONE
- CHANGELOG Unreleased: W2–W3 handbook deltas (Assistant Super+Shift+A, IMAGE_NAME, local build primary / GHCR 403)
- ISSUES merge-prep table: B-5/B-6 closed, B-7 + B-1 open
- ACCURACY-AUDIT B-W4-001; no public GHCR claim; no screenshot binaries; links 0 missing


## 2026-08-13 — B-W3-001

- status OPEN → IN_PROGRESS → DONE
- INSTALL: GHCR framed as private (anonymous 403); Path C local build primary; Path A needs auth
- first-boot: how-you-got-image table (localhost vs GHCR); greeters SDDM/cosmic-greeter kept
- README registry note: prefer just build → localhost/hyprwave
- ISSUES B-1 note; ACCURACY-AUDIT B-W3-001; no screenshot binaries; link check 0 missing


## 2026-08-13 — B-W2-002

- status OPEN → IN_PROGRESS → DONE
- INSTALL Path C: IMAGE_NAME default `image-template`; override `just build hyprwave latest` / env; CI uses repo name; Justfile untouched
- contributor-notes: same IMAGE_NAME guidance
- ISSUES B-6 closed (docs-only)
- screenshot-checklist hygiene: IMAGE_NAME + DE mix-up blockers; C2 dock favorites; all Status TODO; no binaries
- ACCURACY-AUDIT B-W2-002 addendum
- Duress off-by-default / GHCR public not claimed

## 2026-08-13 — B-W2-001

- status OPEN → IN_PROGRESS → DONE
- Merged origin/main into lane/b-docs (conflict only in CURRENT_TASK; took main)
- README: Assistant companion + stack + Optional extras (shipped, not upcoming)
- docs/keybinds.md: Super+Shift+A → ghostty -e hyprwave-assistant (skel-accurate)
- ISSUES B-5 closed; faq Q15 + security Assistant sections updated
- COSMIC dock confirmed vs favorites file
- Link check (fenced examples excluded): 263 / 0 missing
- GHCR not claimed public; duress still off by default

## 2026-08-07 — B-W1-001

- status OPEN → IN_PROGRESS → DONE
- Handbook: theming, faq (18 Qs), contributor-notes; expanded docs/README index
- ACCURACY-AUDIT.md from skel/bindings/build.sh/iso/Justfile/themes
- Screenshot checklist: purpose + alt text + capture notes (all TODO binaries)
- INSTALL/CHANGELOG/README linked into handbook; GHCR private + duress off-by-default preserved
- Validation: 142 relative links OK; 0 missing; faq_questions=18
- Commits: 2939e8a, a0cd961, + polish/DONE tip on push

## 2026-08-07 — B-W1-002

- status OPEN → IN_PROGRESS → DONE
- keybinds.md reconciled to origin/lane/e-hyprland KEYBIND-MAP + bindings.conf
  (Super+Shift+E exit, vim focus/move/resize, dwindle splitratio; merge honesty vs main)
- New docs/first-boot.md: greeter → chrome → tour → theme → updates; A checklist + F greeter as lane paths
- INSTALL: dual-variant decision tree + ISO vs rebase; private GHCR contingency preserved
- CHANGELOG Unreleased: Wave-1 A–G pending merge table; no false shipped-on-main claims
- docs/cosmic.md: F GREETER/SESSION-SMOKE/VENDOR cross-links
- ACCURACY-AUDIT.md refreshed for keybind + first-boot sources
- Relative links: 181 checked, 0 missing (fenced examples ignored)
- Commits: e16055a, 5367ffe, 79c4c04 (+ DONE tip 7614d2b)

## 2026-08-07 — B-W1-003

- status OPEN → IN_PROGRESS → DONE
- security.md: D-lane THREAT-MODEL/ENABLE/FAQ alignment; off-by-default; no LUKS claims; no enable paste
- troubleshooting.md: dual-variant matrix (greeter, Walker vs COSMIC launcher, themes both)
- screenshot-checklist.md: every row purpose + alt + exact hyprshot/grim command; compositor blockers
- docs/screenshots.md index; docs/assets/ reserved (no binaries)
- README Docs bar emphasizes first-boot + keybinds + security
- ACCURACY-AUDIT B-W1-003 addendum; relative links 205/0 missing
- Product commits: security, troubleshooting, screenshots, README/audit

## 2026-08-07 — B-W1-004

- status OPEN → IN_PROGRESS → DONE
- CHANGELOG: final A–G pending-merge table + Post-merge template for integrator
- architecture.md: bootc + dual DE + theme store + Assistant/duress packaging boundaries
- contributor-notes.md: refresh handbook after merges; PROTOCOL link
- ACCURACY-AUDIT freeze note (main tip 371ea34); links 220/0 missing
- ≥3 product commits; push lane/b-docs

## 2026-08-07 — B-W1-005

- status OPEN → IN_PROGRESS → DONE
- Added planning/integration/b-docs/POST-MERGE-DOC-FLIP.md (integrator checklist)
- CHANGELOG Post-merge template links to flip file
- contributor-notes + ACCURACY-AUDIT post-merge pass stub
- Links 245/0 missing; ≥2 commits; push lane/b-docs

## 2026-08-07 — B-W1-006

- status OPEN → DONE (integration standby heartbeat)
- Wave 1 product docs **frozen**; no product scope this tick
- Freeze / lane tip: `fb3eb36`
- Standby for integration (Director serial merge / INTEGRATION-DAY)
- Optional self-check: relative links checked=245 missing=0
