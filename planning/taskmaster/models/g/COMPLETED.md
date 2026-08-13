# Model G Completed Tasks

(append: `task_id | date | one-line summary | tip commit`)

G-W1-001 | 2026-08-07 | QA harness (run-all + 5 checks), MERGE-PLAYBOOK, SMOKE-MATRIX | c2f26ff
G-W1-002 | 2026-08-07 | lane-artifacts + ENDPOINT-RESIDUALS + ci-snippet + playbook flips | e993e8f
G-W1-003 | 2026-08-07 | pre-merge dry-run + merge-tree probe + GHCR gates | 1c8822d
G-W1-004 | 2026-08-07 | INTEGRATION-DAY master runbook + residual tip refresh | a4562aa
G-W1-005 | 2026-08-07 | PROGRAM-CLOSEOUT ENDPOINT verify matrix | fb18b31
G-W2-001 | 2026-08-13 | check-image.sh + T8 residual flip (CI+local PASS; VM/GHCR open) | d13e250
G-W2-003 | 2026-08-13 | ci-snippet packaging-qa-image advisory job + README/residuals | 04f54b4
G-W3-001 | 2026-08-13 | check-image --cosmic PASS; residuals narrowed to VM+GHCR | 32b310d
G-W4-001 | 2026-08-13 | product-only probe clean; PRE-MERGE-DRY-RUN A/B/C on main | 613afbd

## G-W5-001 — Post-merge harness + check-image (2026-08-13)
- Wave 2–4 already on main (`07be046`); lane/g-qa merge was up-to-date.
- Expanded `check-no-wofi-swaybg.sh` migration-comment filter (`are/is not used`, `no wofi`, etc.) so E/C negation comments PASS.
- `run-all.sh` → **RESULT OK** (7/7).
- `check-image` hyprland + cosmic → **18 PASS** (local tags present).

## G-W6-001 — no-wofi “not used” false FAIL (2026-08-13)
- Issued DONE by orchestrator: work already in G-W5-001 `9f50998` / main `c712cbd`.
- No additional exclusive G changes required.
