# Pre-merge dry-run (A→G)

**Owner:** Model G — **read-only** analysis; does **not** merge product lanes.  
**Generated:** 2026-08-07 (UTC)  
**Refreshed:** 2026-08-13 (G-W4-001)  
**Base:** `origin/main` @ `f2fcb76`  
**Tooling:** `bash planning/qa/probe-merge-conflicts.sh --product-only`  
**Day-of procedure:** [INTEGRATION-DAY.md](./INTEGRATION-DAY.md)

Re-run after any lane tip moves:

```bash
git fetch origin
bash planning/qa/probe-merge-conflicts.sh --product-only
# optional hard gate:
# bash planning/qa/probe-merge-conflicts.sh --product-only --fail-on-conflict
```

---

## 0. Executive go / no-go (Wave 4)

| Gate | Status | Notes |
|---|---|---|
| All seven lane tips fetchable | **GO** | See §1 SHAs |
| Product-only probe vs main | **GO** | **0** product CONFLICT lines; all seven PASS (`--fail-on-conflict` exit 0) |
| **A already on main** | **GO / done** | `42450b1` merge: lane/a-stabilize Wave 2–4; pins on main (0× `/releases/latest`) |
| **B already on main** | **GO / done** | `5ef86b6` merge: lane/b-docs Wave 2–4 |
| **C already on main** | **GO / done** | `83f6f8c` merge: lane/c-assistant Wave 2–4 |
| D product still lane-only | **GO to merge** | 12 product paths; **product-clean** merge-tree |
| E residual docs | **GO** | 2 integration docs only; product-clean |
| F residual docs / iso | **GO** | 6 paths; product-clean (taskmaster noise only) |
| G qa residual | **GO** | 7 paths (check-image + residuals); product-clean |
| Taskmaster conflicts | **WARN** | Expected on F/G when full merge; prefer model trees / main director files |
| VM qcow2 smoke | **open** | Human residual — do not claim done |
| GHCR anonymous pull | **open** | Still **403** — do not claim public |

**Integrator recommendation:** A/B/C Wave 2–4 product is **already on main**. Next serial product merges: **D → E residual → F residual → G**. Product path risk remains **low** (pairwise product-clean). Residual risk is **VM smoke + GHCR policy**, not three-way skel wars.

---

## 1. Lane tips (fetched 2026-08-13T03:51Z)

| Lane | Ref | Tip SHA | Merge-base w/ main | Product files* | On main? |
|---|---|---|---|---|---|
| A stabilize | `origin/lane/a-stabilize` | `bd02d47` | `f2fcb76` | **0** | **Yes** — `42450b1` + later |
| B docs | `origin/lane/b-docs` | `6356b4e` | `6356b4e` | **0** | **Yes** — `5ef86b6` |
| C assistant | `origin/lane/c-assistant` | `2496ff6` | `f2fcb76` | **0** | **Yes** — `83f6f8c` |
| D duress | `origin/lane/d-duress` | `176aecd` | `f2fcb76` | **12** | No (product still lane) |
| E hyprland | `origin/lane/e-hyprland` | `f472267` | `995a198` | **2** | Partial (core W1 on main; residual docs) |
| F cosmic | `origin/lane/f-cosmic` | `c596cf6` | `2af9a6c` | **6** | Partial (core W1 on main; residual docs/iso) |
| G qa | `origin/lane/g-qa` | `5ecfd60` | `c9b3085` | **7** | Partial (W1 harness on main; W2–3 image/CI residual) |

\*Product = paths outside `planning/taskmaster/**` changed since merge-base with `origin/main`.

---

## 2. Pairwise `merge-tree` vs `origin/main` (product-only)

Probe command:

```text
bash planning/qa/probe-merge-conflicts.sh --product-only
# base origin/main @ f2fcb76 — RESULT OK; Total CONFLICT lines: 0
```

| Lane | Product conflicts | Product files | Verdict |
|---|---|---|---|
| A | **none** | 0 | Clean — already integrated |
| B | **none** | 0 | Clean — already integrated |
| C | **none** | 0 | Clean — already integrated |
| D | **none** | 12 | Product clean — ready to merge |
| E | **none** | 2 | Product clean |
| F | **none** (taskmaster filtered) | 6 | Product clean |
| G | **none** (taskmaster filtered) | 7 | Product clean |

`--fail-on-conflict` exit: **0**.

### Remaining product path inventory (not yet on main)

#### D — `176aecd`

- `build_files/duress/{ENABLE.md,README.md,hyprwave-duress-setup}`
- `planning/integration/d-duress/**` (DRILL, ENABLE, checklists, snippets, validate, selftest, residuals)

**Post-merge:** apply snippets if not already on main; keep PAM **off**.

#### E — `f472267`

- `planning/integration/e-hyprland/HANDOFF.md`
- `planning/integration/e-hyprland/KEYBIND-MAP.md`

#### F — `c596cf6`

- `disk_config/iso-cosmic.toml`
- `planning/integration/f-cosmic/{FREEZE-STATUS,GREETER,IMAGE-INSPECT,README,SESSION-SMOKE}.md`

#### G — `5ecfd60` (+ later W4 tip)

- `planning/qa/{check-image.sh,ci-snippet.yml,run-all.sh,README.md}`
- `planning/integration/g-qa/{ENDPOINT-RESIDUALS,PROGRAM-CLOSEOUT,SMOKE-MATRIX}.md`

---

## 3. Historical Wave 1 note (superseded)

Wave 1 serial merge A→G completed on main earlier (see [ENDPOINT-RESIDUALS.md](./ENDPOINT-RESIDUALS.md)). This G-W4-001 refresh is **Wave 2–4 residual merge-prep**, not a greenfield A→G train.

Pins on main: **0**× `/releases/latest` (A landed). Host harness: green when product tree present.

---

## 4. Residuals (unchanged policy)

| Item | Status |
|---|---|
| Local/CI image builds | **met** (not pending) |
| VM qcow2 session smokes | **open** |
| GHCR anonymous / public pull | **open** (403) |
| PROGRAM_COMPLETE | **open** (Director) |

Do **not** claim VM smoke done. Do **not** claim GHCR public.

---

## 5. Probe log excerpt (G-W4-001)

```
base:  origin/main @ f2fcb76
PASS  a-stabilize @ bd02d47  clean; product_files=0
PASS  b-docs @ 6356b4e       clean; product_files=0
PASS  c-assistant @ 2496ff6  clean; product_files=0
PASS  d-duress @ 176aecd     clean; product_files=12
PASS  e-hyprland @ f472267   clean; product_files=2
PASS  f-cosmic @ c596cf6     product-clean (taskmaster filtered); files=6
PASS  g-qa @ 5ecfd60         product-clean (taskmaster filtered); files=7
Total CONFLICT lines: 0
RESULT: OK
```
