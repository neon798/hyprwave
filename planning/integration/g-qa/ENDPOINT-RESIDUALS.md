# ENDPOINT residuals tracker

**Owner:** Model G (read-only inspection + tracking; does not merge product lanes).  
**Source of truth for “finished”:** `planning/taskmaster/ENDPOINT.md` product items 1–10.  
**Inspection date:** 2026-08-07 (UTC) — G-W1-004 refresh  
**Baseline refs:** `origin/main` @ `6c5da71` + remote-tracking `origin/lane/*` after `git fetch`.  
**Master human procedure:** [INTEGRATION-DAY.md](./INTEGRATION-DAY.md)

| Lane | Tip (short) | Notes |
|---|---|---|
| a-stabilize | `94f08d6` | MERGE-READY on lane |
| b-docs | `fb3eb36` | POST-MERGE-DOC-FLIP on lane |
| c-assistant | `92a1a89` | snippets + HANDOFF |
| d-duress | `4bb5b55` | INTEGRATOR-CHECKLIST |
| e-hyprland | `935fd96` | INTEGRATION-DAY VM card |
| f-cosmic | `7b19270` | INTEGRATOR-CHECKLIST + vendor script |
| g-qa | this branch | harness + integration-day master |

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
| A pins on main | **open** | `versions.env` absent; **met on lane** A |
| B docs on main | **open** | **met on lane** B |
| C assistant on main | **open** | **met on lane** C; snippets post-merge |
| D duress on main | **open** | **met on lane** D |
| E Hyprland polish | **partial** | baseline skel on main; E polish **met on lane** |
| F COSMIC | **partial** | baseline vendor on main; F freeze **met on lane** |
| G QA on main | **open** | **met on lane** G |

**Residual:** Follow INTEGRATION-DAY.md serial A→G + C/D snippets.

---

### 2. Hyprland image builds with pinned binaries

| Criterion | Status | Evidence |
|---|---|---|
| No `/releases/latest` on main | **open** | main still **6** hits; pins-static FAIL |
| A lane pinned | **met on lane** | 0 hits + versions.env |
| `just build` green | **open** | integrator T8 |

---

### 3. COSMIC image builds with vendor defaults

| Criterion | Status | Evidence |
|---|---|---|
| DE=cosmic path | **partial** | on main; F checklist on lane |
| Vendor + Mode dark / favorites | **met on main** + F delta **met on lane** | |
| `just build-cosmic` | **open** | T8 |

---

### 4. Assistant in image + offline KB

| Criterion | Status | Evidence |
|---|---|---|
| Sources/tests | **met on lane** C | |
| Image stages | **open** | snippet apply |
| Super+Shift+A | **open** | E card / C HANDOFF |

---

### 5. Duress packaged OFF by default

| Criterion | Status | Evidence |
|---|---|---|
| Packaging + validate | **met on lane** D | |
| No `*.sha256` | **met on lane** | |
| OFF in shipped image | **open** until merge verify | |

---

### 6. Desktop Hyprland coherent

| Criterion | Status | Evidence |
|---|---|---|
| Walker/waybar/hyprpaper stack | **met on main** + E on lane | no-wofi PASS on G tree |
| Themes structure | **met on main** | themes PASS (11) |
| Keybinds docs | **partial** | B+E on lanes |

---

### 7. COSMIC on-brand / FlatArcade store

| Criterion | Status | Evidence |
|---|---|---|
| Greeter/inventory/checklist | **met on lane** F | |
| Session smoke | **open** | VM |

---

### 8. Docs handbook

| Criterion | Status | Evidence |
|---|---|---|
| INSTALL/CHANGELOG/docs | **met on lane** B | not on main |
| Accuracy post-merge | **open** | B POST-MERGE-DOC-FLIP |

---

### 9. QA automated + integration procedure

| Criterion | Status | Evidence |
|---|---|---|
| Harness, probe, CI snippet, dry-run | **met on lane** G | |
| INTEGRATION-DAY master runbook | **met on lane** G | this task |
| On main | **open** | merge G |

---

### 10. Release path / GHCR

| Criterion | Status | Evidence |
|---|---|---|
| RELEASE/COSIGN/FIRST-BOOT | **met on lane** A | |
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
