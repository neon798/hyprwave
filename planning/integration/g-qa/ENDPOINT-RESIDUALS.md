# ENDPOINT residuals tracker

**Owner:** Model G (read-only inspection + tracking; does not merge product lanes).  
**Source of truth for “finished”:** `planning/taskmaster/ENDPOINT.md` product items 1–10.  
**Inspection date:** 2026-08-07 (UTC) — G-W1-005 refresh  
**Baseline refs:** `origin/main` @ `98fe075` + remote-tracking `origin/lane/*` after `git fetch`.  
**Master human procedure:** [INTEGRATION-DAY.md](./INTEGRATION-DAY.md)  
**Closeout verify matrix:** [PROGRAM-CLOSEOUT.md](./PROGRAM-CLOSEOUT.md)

| Lane | Tip (short) | Notes |
|---|---|---|
| a-stabilize | `0dbde46` | MERGE-READY on lane |
| b-docs | `4ababf9` | POST-MERGE-DOC-FLIP on lane |
| c-assistant | `2dafc3b` | snippets + HANDOFF |
| d-duress | `84371bb` | INTEGRATOR-CHECKLIST |
| e-hyprland | `985b441` | INTEGRATION-DAY VM card |
| f-cosmic | `a4cdb8a` | INTEGRATOR-CHECKLIST + vendor script |
| g-qa | this branch | harness + integration-day + closeout |

Status vocabulary:

| Status | Meaning |
|---|---|
| **met on main** | Artifact / property present on `origin/main` |
| **met on lane** | Present on the owning `origin/lane/*` tip, **not** yet on main |
| **partial** | Some sub-criteria met; residual noted |
| **open** | Not met on main (or requires merge + manual snippet apply) |
| **deferred** | Explicitly out of program scope (ENDPOINT non-goals) |

Re-run:

```bash
git fetch origin
bash planning/qa/probe-merge-conflicts.sh --product-only
test -f planning/qa/run-all.sh && bash planning/qa/run-all.sh || true
```

Probe (G-W1-004): all seven lanes **product-clean** vs main (taskmaster-only conflicts filtered).

---

## Product items (ENDPOINT § Product)

### 1. Integrated main contains Wave 1+2 lanes

| Criterion | Status | Evidence / residual |
|---|---|---|
| A pins on main | **met on main** | merged `lane/a-stabilize`; pins-static PASS |
| B docs on main | **met on main** | merged `lane/b-docs`; INSTALL/CHANGELOG/docs present |
| C assistant on main | **met on main** | merged `lane/c-assistant` + snippets applied; assistant PASS |
| D duress on main | **met on main** | merged `lane/d-duress` + snippets applied; duress-safety PASS |
| E Hyprland polish | **met on main** | merged `lane/e-hyprland`; themes/no-wofi PASS |
| F COSMIC | **met on main** | merged `lane/f-cosmic`; vendor check PASS |
| G QA on main | **met on main** | merged `lane/g-qa`; full run-all RESULT OK |

**Residual:** image builds (`just build` / `just build-cosmic`) + VM smokes + GHCR decision = T8.

---

### 2. Hyprland image builds with pinned binaries

| Criterion | Status | Evidence |
|---|---|---|
| No `/releases/latest` on main | **met on main** | 0 hits; pins-static PASS |
| A lane pinned | **met on main** | 0 hits + versions.env |
| `just build` green | **open** | integrator T8 |

---

### 3. COSMIC image builds with vendor defaults

| Criterion | Status | Evidence |
|---|---|---|
| DE=cosmic path | **met on main** | F checklist + vendor on main |
| Vendor + Mode dark / favorites | **met on main** | |
| `just build-cosmic` | **open** | T8 (in progress 2026-08-13) |

---

### 4. Assistant in image + offline KB

| Criterion | Status | Evidence |
|---|---|---|
| Sources/tests | **met on main** | `go test ./...` green on main |
| Image stages | **met on main** | assistant-builder stage + COPY; build.sh snippet |
| Super+Shift+A | **met on main** | bind enabled in skel bindings.conf |

---

### 5. Duress packaged OFF by default

| Criterion | Status | Evidence |
|---|---|---|
| Packaging + validate | **met on main** | validate.sh PASS on main |
| No `*.sha256` | **met on main** | 0 files |
| OFF in shipped image | **open** | verify in built image (T8) |

---

### 6. Desktop Hyprland coherent

| Criterion | Status | Evidence |
|---|---|---|
| Walker/waybar/hyprpaper stack | **met on main** | no-wofi PASS |
| Themes structure | **met on main** | themes PASS (11) |
| Keybinds docs | **met on main** | POST-MERGE-DOC-FLIP 2026-08-13 |

---

### 7. COSMIC on-brand / FlatArcade store

| Criterion | Status | Evidence |
|---|---|---|
| Greeter/inventory/checklist | **met on main** | F docs on main |
| Session smoke | **open** | VM |

---

### 8. Docs handbook

| Criterion | Status | Evidence |
|---|---|---|
| INSTALL/CHANGELOG/docs | **met on main** | merged `lane/b-docs` |
| Accuracy post-merge | **met on main** | POST-MERGE-DOC-FLIP 2026-08-13; GHCR not claimed |

---

### 9. QA automated + integration procedure

| Criterion | Status | Evidence |
|---|---|---|
| Harness, probe, CI snippet, dry-run | **met on main** | merged `lane/g-qa` |
| INTEGRATION-DAY master runbook | **met on main** | merged `lane/g-qa` |
| On main | **met on main** | full run-all RESULT OK |

---

### 10. Release path / GHCR

| Criterion | Status | Evidence |
|---|---|---|
| RELEASE/COSIGN/FIRST-BOOT | **met on main** | A docs merged |
| Publish minimum green | **open** | SMOKE-MATRIX §9 + INTEGRATION-DAY §8 |
| Pins on main | **open** | item 2 |

---

## Process residuals

| Item | Status |
|---|---|
| Ownership clear | **met** |
| Residuals listed | **this file** |
| PROGRAM_COMPLETE | **open** (Director after integration day) |
| Non-goals | **deferred** |

---

## Expected harness flips

| After | Check | Flip |
|---|---|---|
| A | pins-static | FAIL→PASS |
| C+snippets | assistant | WARN→PASS |
| D+snippets | duress-safety | WARN→PASS |
| G | full run-all | present + RESULT OK |
