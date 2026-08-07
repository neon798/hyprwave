# ENDPOINT residuals tracker

**Owner:** Model G (read-only inspection + tracking; does not merge product lanes).  
**Source of truth for “finished”:** `planning/taskmaster/ENDPOINT.md` product items 1–10.  
**Inspection date:** 2026-08-07 (UTC) — G-W1-003 + poll refresh  
**Baseline refs:** `origin/main` @ `371ea34` + remote-tracking `origin/lane/*` after `git fetch`.

| Lane | Tip (short) |
|---|---|
| a-stabilize | `3022cfc` |
| b-docs | `6be80a8` |
| c-assistant | `0c9838a` |
| d-duress | `b69a474` |
| e-hyprland | `b9a218f` |
| f-cosmic | `799d952` |
| g-qa | this branch |

Status vocabulary:

| Status | Meaning |
|---|---|
| **met on main** | Artifact / property present on `origin/main` |
| **met on lane** | Present on the owning `origin/lane/*` tip, **not** yet on main |
| **partial** | Some sub-criteria met; residual noted |
| **open** | Not met on main or the expected lane (or requires merge + manual snippet apply) |
| **deferred** | Explicitly out of program scope (see ENDPOINT non-goals) |

Re-run: `git fetch origin && bash planning/qa/run-all.sh && bash planning/qa/probe-merge-conflicts.sh --product-only`

Pre-merge narrative: `PRE-MERGE-DRY-RUN.md`.

---

## Product items (ENDPOINT § Product)

### 1. Integrated main contains Wave 1+2 lanes

| Criterion | Status | Evidence / residual |
|---|---|---|
| Pins / stabilize (A) on main | **open** | `versions.env` absent on main; **met on lane** A |
| Docs (B) on main | **open** | INSTALL/CHANGELOG/docs **met on lane** B |
| Assistant (C) on main | **open** | app + share **met on lane** C; snippets not applied |
| Duress packaging (D) on main | **open** | **met on lane** D |
| Hyprland polish (E) on main | **partial** | baseline skel on main; E polish/docs **met on lane** |
| COSMIC vendor (F) on main | **partial** | vendor baseline on main; F docs/fixes **met on lane** |
| QA harness (G) on main | **open** | **met on lane** G only |

**Residual:** Serial merge A→G; C/D snippet apply. Product pairwise merge-tree: **clean** (taskmaster-only conflicts).

---

### 2. Hyprland image builds with pinned binaries (no `/releases/latest`)

| Criterion | Status | Evidence / residual |
|---|---|---|
| No `/releases/latest` on main `build.sh` | **open** | main: **6** hits; `pins-static` FAIL |
| Pins on A lane | **met on lane** | A tip: **0** hits; `versions.env` present |
| `just build` green post-A | **open** | Integrator/CI |

---

### 3. COSMIC image builds with vendor defaults intact

| Criterion | Status | Evidence / residual |
|---|---|---|
| Packaging path `DE=cosmic` | **partial** | on main; F smoke/inventory on lane |
| Vendor under `build_files/usr/share/cosmic/` | **met on main** + F delta on lane | favorites / `is_dark` on F |
| `just build-cosmic` green | **open** | Integrator/CI |

---

### 4. Assistant built into image (or gated) + offline KB/catalog

| Criterion | Status | Evidence / residual |
|---|---|---|
| App sources + tests | **met on lane** C | `apps/hyprwave-assistant` |
| Image install stages | **open** | snippets only |
| Desktop + KB share | **met on lane** C | note: accidental main KB paths removed in `121ea50` |
| Super+Shift+A | **open** | E reserves bind **commented** until C in image |

---

### 5. Duress packaged, OFF by default; ENABLE; validate; no pre-signed scripts

| Criterion | Status | Evidence / residual |
|---|---|---|
| Packaging + ENABLE | **met on lane** D | |
| `validate.sh` | **met on lane** D | |
| No `*.sha256` | **met on lane** | |
| OFF by default in shipped image | **open** until merge + snippet verify | |

---

### 6. Desktop (Hyprland skel) coherent

| Criterion | Status | Evidence / residual |
|---|---|---|
| Walker / waybar / mako / hyprpaper | **met on main** + E polish on lane | `no-wofi-swaybg` PASS on G tree |
| Keybinds doc vs reality | **partial** | B docs + E KEYBIND-MAP on lanes |
| Theme pack structure | **met on main** | `themes` PASS (11); exceptions empty |

---

### 7. COSMIC greeter/session on-brand; FlatArcade; no store regression

| Criterion | Status | Evidence / residual |
|---|---|---|
| Greeter / inventory docs | **met on lane** F | |
| Favorites / theme mode | **met on lane** F (delta) | |
| Session smoke | **open** | VM |

---

### 8. Docs: INSTALL, CHANGELOG, troubleshooting, architecture, keybinds

| Criterion | Status | Evidence / residual |
|---|---|---|
| Handbook set | **met on lane** B | not on main |
| Accuracy vs final tree | **open** | re-audit after A–F merge |

---

### 9. QA automated checks documented and runnable

| Criterion | Status | Evidence / residual |
|---|---|---|
| Harness + lane-artifacts + CI snippet | **met on lane** G | |
| Pre-merge probe script | **met on lane** G | `probe-merge-conflicts.sh` (not in run-all) |
| Dry-run + publish gates | **met on lane** G | PRE-MERGE-DRY-RUN + SMOKE-MATRIX §9 |
| On main | **open** | merge G last |

---

### 10. Release path: GHCR, first-boot, no silent latest downloads

| Criterion | Status | Evidence / residual |
|---|---|---|
| RELEASE / FIRST-BOOT / COSIGN docs | **met on lane** A | |
| Pin discipline on main | **open** | item 2 |
| GHCR publish minimum green | **open** | SMOKE-MATRIX §9 |

---

## Process residuals

| Item | Status |
|---|---|
| Ownership A–G clear | **met** |
| Residuals listed | **this file** |
| PROGRAM_COMPLETE | **open** (Director) |
| Non-goals | **deferred** |

---

## Expected harness flips after merges

| After | Check | Before | After |
|---|---|---|---|
| A | `pins-static` | FAIL | PASS |
| C + snippets | `assistant` | WARN | PASS |
| D + snippets | `duress-safety` | WARN | PASS |
| E/F | themes / no-wofi | PASS | PASS |
| G on main | full harness | absent | runnable |
| any (fetched) | `lane-artifacts` | PASS if refs present | PASS |

Publish gates: **SMOKE-MATRIX §9**. Conflict narrative: **PRE-MERGE-DRY-RUN.md**.
