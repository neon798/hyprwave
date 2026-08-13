# ENDPOINT residuals tracker

**Owner:** Model G (read-only inspection + tracking; does not merge product lanes).  
**Source of truth for “finished”:** `planning/taskmaster/ENDPOINT.md` product items 1–10.  
**Inspection date:** 2026-08-13 (UTC) — G-W2-001 T8 residual refresh  
**Baseline refs:** `origin/main` @ `045391f` (Wave 1 merged+pushed) + host image inspect.  
**Master human procedure:** [INTEGRATION-DAY.md](./INTEGRATION-DAY.md)  
**Closeout verify matrix:** [PROGRAM-CLOSEOUT.md](./PROGRAM-CLOSEOUT.md)

| Source | Tip / id | Notes |
|---|---|---|
| origin/main | `045391f` (fetch-time) | Wave 1 A→G on main |
| CI build | run `31662742064` | Both hyprland + cosmic variants **PASS** (Director) |
| Local hyprland image | `localhost/hyprwave:latest` | Inspected via `check-image.sh` — **PASS** |
| Local cosmic image | `localhost/hyprwave-cosmic:latest` | Inspected via `check-image.sh` — **PASS** |
| GHCR anonymous pull | — | Still **403** (public pull open residual) |
| VM session smoke | — | **open** (human T8) |

Status vocabulary:

| Status | Meaning |
|---|---|
| **met on main** | Artifact / property present on `origin/main` |
| **met on lane** | Present on the owning `origin/lane/*` tip, **not** yet on main |
| **partial** | Some sub-criteria met; residual noted |
| **open** | Not met (or requires manual/VM/GHCR step) |
| **deferred** | Explicitly out of program scope (ENDPOINT non-goals) |

Re-run:

```bash
git fetch origin
bash planning/qa/run-all.sh
# image check alone (skip-if-missing):
bash planning/qa/run-all.sh --only image
```

---

## Product items (ENDPOINT § Product)

### 1. Integrated main contains Wave 1+2 lanes

| Criterion | Status | Evidence / residual |
|---|---|---|
| A pins on main | **met on main** | `versions.env` present; 0× `/releases/latest` |
| B docs on main | **met on main** | INSTALL/CHANGELOG/docs present |
| C assistant on main | **met on main** | `apps/hyprwave-assistant` + image binary |
| D duress on main | **met on main** | packaging + ENABLE.md; PAM OFF in image |
| E Hyprland polish | **met on main** | skel + themes on main |
| F COSMIC | **met on main** | cosmic image + greeter; vendor on main |
| G QA on main | **met on main** | harness + integration docs; image check added G-W2-001 |

**Residual:** Wave 2 follow-ups only; Wave 1 integration complete on main.

---

### 2. Hyprland image builds with pinned binaries

| Criterion | Status | Evidence |
|---|---|---|
| No `/releases/latest` on main | **met on main** | pins-static PASS |
| A lane pinned | **met on main** | versions.env |
| `just build` green | **met** (local + CI) | local `localhost/hyprwave:latest`; CI run `31662742064` PASS |
| Image content smoke | **met** | `bash planning/qa/run-all.sh --only image` PASS |

---

### 3. COSMIC image builds with vendor defaults

| Criterion | Status | Evidence |
|---|---|---|
| DE=cosmic path | **met on main** | |
| Vendor + Mode dark / favorites | **met on main** | |
| `just build-cosmic` | **met** (local + CI) | `localhost/hyprwave-cosmic:latest`; CI `31662742064` |
| Image content smoke | **met** | check-image cosmic asserts PASS |

---

### 4. Assistant in image + offline KB

| Criterion | Status | Evidence |
|---|---|---|
| Sources/tests | **met on main** | `go test ./...` via harness |
| Image binary | **met** | `hyprwave-assistant 0.2.2` in image |
| catalog.toml | **met** | `/usr/share/hyprwave/assistant/catalog.toml` |
| Super+Shift+A | **partial** | bind may be host/skel; not re-verified in VM |

---

### 5. Duress packaged OFF by default

| Criterion | Status | Evidence |
|---|---|---|
| Packaging + validate | **met on main** | duress-safety PASS |
| No `*.sha256` | **met on main** | |
| ENABLE.md in image | **met** | `/usr/share/hyprwave/duress/ENABLE.md` |
| OFF in shipped PAM | **met** | no `pam_duress` in image `/etc/pam.d` |

---

### 6. Desktop Hyprland coherent

| Criterion | Status | Evidence |
|---|---|---|
| Walker/waybar/hyprpaper stack | **met** | image bins + no-wofi-swaybg PASS |
| Themes structure | **met** | 11 themes in image + themes check |
| VM session smoke | **open** | human T8 residual |

---

### 7. COSMIC on-brand / FlatArcade store

| Criterion | Status | Evidence |
|---|---|---|
| Greeter in image | **met** | cosmic-greeter enabled |
| No cosmic-store | **met** | package/binary absent |
| FlatArcade | **met** | flatarcade present |
| Session smoke | **open** | VM residual |

---

### 8. Docs handbook

| Criterion | Status | Evidence |
|---|---|---|
| INSTALL/CHANGELOG/docs | **met on main** | post-merge flip landed |
| Accuracy | **partial** | B may still polish Wave 2 |

---

### 9. QA automated + integration procedure

| Criterion | Status | Evidence |
|---|---|---|
| Harness + probe + CI snippet | **met on main** | |
| `check-image.sh` skip-if-missing | **met** | G-W2-001; registered after `assistant` |
| INTEGRATION-DAY / closeout | **met on main** | |
| Host harness RESULT OK | **met** | run-all PASS including image |

---

### 10. Release path / GHCR

| Criterion | Status | Evidence |
|---|---|---|
| RELEASE/COSIGN/FIRST-BOOT docs | **met on main** | A artifacts |
| CI image builds | **met** | run `31662742064` both variants PASS |
| GHCR public/anonymous pull | **open** | anonymous still **403** |
| Signed publish “Wave 1 integrated” | **open** | human/Director after VM + §9 soft gates |

---

## Process residuals

| Item | Status |
|---|---|
| Ownership clear | **met** |
| Residuals listed | **this file** (G-W2-001 refresh) |
| PROGRAM_COMPLETE | **open** (Director — VM smoke + GHCR policy) |
| Non-goals | **deferred** |

---

## T8 scoreboard (image / VM / GHCR)

| Gate | Status | Notes |
|---|---|---|
| Host `run-all.sh` | **met** | RESULT OK |
| CI hyprland + cosmic | **met** | `31662742064` |
| Local hyprland inspect | **met** | check-image PASS |
| Local cosmic inspect | **met** | check-image PASS |
| VM Hyprland session | **open** | human |
| VM COSMIC session | **open** | human |
| GHCR anonymous pull | **open** | 403 |
| PROGRAM_COMPLETE | **open** | Director |

---

## Expected harness flips (historical Wave 1)

| After | Check | Flip |
|---|---|---|
| A | pins-static | FAIL→PASS (done) |
| C+snippets | assistant | WARN→PASS (done) |
| D+snippets | duress-safety | WARN→PASS (done) |
| local build | image | SKIP→PASS when `localhost/hyprwave:latest` exists |
| G | full run-all | RESULT OK |

