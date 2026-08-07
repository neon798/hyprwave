# ENDPOINT residuals tracker

**Owner:** Model G (read-only inspection + tracking; does not merge product lanes).  
**Source of truth for “finished”:** `planning/taskmaster/ENDPOINT.md` product items 1–10.  
**Inspection date:** 2026-08-07 (UTC)  
**Baseline refs:** `origin/main` @ `3a9cb79` + remote-tracking `origin/lane/*` after `git fetch`.

Status vocabulary:

| Status | Meaning |
|---|---|
| **met on main** | Artifact / property present on `origin/main` |
| **met on lane** | Present on the owning `origin/lane/*` tip, **not** yet on main |
| **partial** | Some sub-criteria met; residual noted |
| **open** | Not met on main or the expected lane (or requires merge + manual snippet apply) |
| **deferred** | Explicitly out of program scope (see ENDPOINT non-goals) |

Re-run: after each serial merge, update this table (or regenerate notes) so Director can close with `PROGRAM_COMPLETE` only when open rows are empty or deferred.

---

## Product items (ENDPOINT § Product)

### 1. Integrated main contains Wave 1+2 lanes

| Criterion | Status | Evidence / residual |
|---|---|---|
| Pins / stabilize (A) on main | **open** | `build_files/versions.env` absent on main; **met on lane** `origin/lane/a-stabilize` |
| Docs (B) on main | **open** | `INSTALL.md` / `CHANGELOG.md` / `docs/**` **met on lane** `origin/lane/b-docs` |
| Assistant (C) on main | **open** | `apps/hyprwave-assistant/**` **met on lane** `origin/lane/c-assistant`; snippets not applied on main |
| Duress packaging (D) on main | **open** | `build_files/duress/**` + `validate.sh` **met on lane** `origin/lane/d-duress` |
| Hyprland polish (E) on main | **partial** | Main already has skel/themes from pre-program work; E adds SESSION-SMOKE / KEYBIND-MAP / polish — **met on lane** `origin/lane/e-hyprland` |
| COSMIC vendor (F) on main | **partial** | Main ships cosmic vendor tree; F inventory/smoke docs **met on lane** `origin/lane/f-cosmic` |
| QA harness (G) on main | **open** | `planning/qa/**` **met on lane** `origin/lane/g-qa` only |

**Residual:** Serial merge A→B→C→D→E→F→G per `MERGE-PLAYBOOK.md`; C/D **snippet apply** after git merge.

---

### 2. Hyprland image builds with pinned binaries (no `/releases/latest`)

| Criterion | Status | Evidence / residual |
|---|---|---|
| No `/releases/latest` in `build_files/build.sh` on main | **open** | main: **6** hits; harness `pins-static` **FAIL** on unpinned baseline |
| Pins on A lane | **met on lane** | `origin/lane/a-stabilize`: **0** `/releases/latest`; `versions.env` present |
| `just build` green post-A | **open** | Requires merge + CI/host build (not run by G) |

**Residual:** Merge A; expect harness `pins-static` FAIL→PASS; run `just build`.

---

### 3. COSMIC image builds with vendor defaults intact

| Criterion | Status | Evidence / residual |
|---|---|---|
| COSMIC group / greeter packaging path | **partial** | Containerfile `DE=cosmic` on main; F vendor inventory/smoke docs on lane |
| Vendor defaults under `build_files/usr/share/cosmic/` | **met on main** (baseline) / **met on lane** F for docs | Confirm post-F with `VENDOR-INVENTORY.md` |
| `just build-cosmic` green | **open** | Integrator VM/CI |

**Residual:** Merge F; run `just build-cosmic`; walk F SESSION-SMOKE.

---

### 4. Assistant built into image (or gated) + offline KB/catalog

| Criterion | Status | Evidence / residual |
|---|---|---|
| App sources + tests | **met on lane** C | `apps/hyprwave-assistant`, `go test` via harness when tree present |
| Image install (Containerfile + build.sh) | **open** | Snippets only on C; not applied on main |
| Desktop entry / launch path | **met on lane** C | `build_files/usr/share/applications/hyprwave-assistant.desktop` |
| Super+Shift+A bind | **open** | Handoff on C; skel bind owned by E merge or manual single-line apply |

**Residual:** Merge C + apply snippets; harness `assistant` WARN→PASS; optional E bind.

---

### 5. Duress packaged, OFF by default; ENABLE.md; validate green; no pre-signed scripts

| Criterion | Status | Evidence / residual |
|---|---|---|
| Packaging tree + ENABLE.md | **met on lane** D | `build_files/duress/**` |
| `validate.sh` | **met on lane** D | `planning/integration/d-duress/validate.sh` |
| No `*.sha256` on D | **met on lane** | `git ls-tree` scan: none |
| OFF by default on main image | **open** until merge | Snippet contract forbids live PAM enable; verify post-merge |
| Image stages copy assets | **open** | D Containerfile/build.sh snippets must be applied |

**Residual:** Merge D + snippets; harness `duress-safety` WARN→PASS; never commit signatures.

---

### 6. Desktop (Hyprland skel) coherent

| Criterion | Status | Evidence / residual |
|---|---|---|
| Walker / waybar / mako / hyprpaper stack | **met on main** (baseline) + **met on lane** E docs | harness `no-wofi-swaybg` PASS on main; E autostart documents order |
| Keybinds documented vs reality | **partial** | E `KEYBIND-MAP.md` on lane; B `docs/keybinds.md` on lane — need post-merge accuracy pass |
| Theme pack structure | **met on main** | harness `themes` PASS (11 themes); exceptions list empty |

**Residual:** Merge E (+ B docs); manual SESSION-SMOKE; re-run themes + no-wofi checks.

---

### 7. COSMIC greeter/session on-brand; FlatArcade store; no store regression

| Criterion | Status | Evidence / residual |
|---|---|---|
| Greeter notes | **met on lane** F | `GREETER.md` |
| Favorites / background vendor keys | **met on main** / F | cosmic share tree present |
| FlatArcade as app store | **partial** | Product intent on main; confirm favorites after F |
| No COSMIC store regression | **open** | VM smoke (F SESSION-SMOKE) |

**Residual:** F merge + COSMIC session smoke.

---

### 8. Docs: INSTALL, CHANGELOG, troubleshooting, architecture, keybinds

| Criterion | Status | Evidence / residual |
|---|---|---|
| INSTALL / CHANGELOG | **met on lane** B | not on main |
| docs/* handbook set | **met on lane** B | architecture, troubleshooting, keybinds, etc. |
| Accuracy vs shipped tree | **open** | B `ACCURACY-AUDIT.md` / ISSUES on lane; re-audit after A–F merge |

**Residual:** Merge B; optional README section apply from `b-docs/README-sections.md`.

---

### 9. QA: automated packaging checks documented and runnable

| Criterion | Status | Evidence / residual |
|---|---|---|
| Harness scripts | **met on lane** G | `planning/qa/run-all.sh` + checks |
| Documented exit semantics | **met on lane** G | README + run-all header (0/1/2) |
| CI-ready snippet | **met on lane** G | `planning/qa/ci-snippet.yml` (A may copy) |
| Harness on main | **open** | Merge G last |

**Residual:** Merge G; wire CI from snippet (A or Director).

---

### 10. Release path: GHCR notes, first-boot checklist, no silent `:latest` downloads

| Criterion | Status | Evidence / residual |
|---|---|---|
| RELEASE / FIRST-BOOT | **met on lane** A | `planning/integration/a-stabilize/{RELEASE,FIRST-BOOT-CHECKLIST}.md` |
| Pin discipline (no floating latest) | **met on lane** A / **open** on main | same as item 2 |
| First-boot log template usable | **partial** | A checklist + G `SMOKE-MATRIX.md` |

**Residual:** Merge A (+ G smoke matrix); publish notes when images green.

---

## Process residuals (ENDPOINT § Process)

| Item | Status | Note |
|---|---|---|
| Lanes A–G ownership clear | **met** | Task Master IDENTITY + exclusive paths |
| Residuals listed | **this file** | Update until empty/deferred |
| `STATUS.md` PROGRAM_COMPLETE | **open** | Director only after integration day |
| Non-goals (NVIDIA farm, theme rewrite, marketing site, default PAM duress) | **deferred** | Do not block ENDPOINT |

---

## Expected harness flips after merges

| After merge | Check | Before (typical main) | After (expected) |
|---|---|---|---|
| A | `pins-static` | FAIL (`/releases/latest`) | PASS |
| C + snippets | `assistant` | WARN (missing app) | PASS (`go test`) |
| D + snippets | `duress-safety` | WARN (missing packaging) | PASS (`validate.sh`) |
| E | `themes`, `no-wofi-swaybg` | PASS | PASS (still) |
| any | `lane-artifacts` | WARN missing refs **or** PASS if fetched | PASS paths on remaining unmerged refs; after all on main, still useful pre-fetch |
| G on main | full `run-all.sh` | harness absent | RESULT OK if A–D applied |

---

## How to refresh this tracker

```bash
git fetch origin
bash planning/qa/run-all.sh
bash planning/qa/check-lane-artifacts.sh   # also included in run-all
# Manually re-check ENDPOINT rows against origin/main vs origin/lane/*
```

G does **not** mark PROGRAM_COMPLETE; Director does after integration + smokes.
