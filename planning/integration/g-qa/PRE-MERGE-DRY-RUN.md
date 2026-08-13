# Pre-merge dry-run (A→G)

**Owner:** Model G — **read-only** analysis; does **not** merge product lanes.  
**Generated:** 2026-08-07 (UTC)  
**Refreshed:** 2026-08-07 (G-W1-004)  
**Base:** `origin/main` @ `6c5da71`  
**Tooling:** `bash planning/qa/probe-merge-conflicts.sh` (`git merge-tree --write-tree`)  
**Day-of procedure:** [INTEGRATION-DAY.md](./INTEGRATION-DAY.md)

Re-run after any lane tip moves:

```bash
git fetch origin
bash planning/qa/probe-merge-conflicts.sh --product-only
# optional hard gate:
# bash planning/qa/probe-merge-conflicts.sh --fail-on-conflict
```

---

## 0. Executive go / no-go

| Gate | Status | Notes |
|---|---|---|
| All seven lane tips fetchable | **GO** | See §1 SHAs |
| Product trees mostly additive vs main | **GO** | No product both-changed hotspots vs current main |
| Taskmaster file conflicts expected | **WARN** | `planning/taskmaster/**` add/add or content conflicts on every lane — resolve by taking **lane tip for that model’s tree** or **main director files** for STATUS/DIRECTOR_LOG; never block product merge on CURRENT_TASK noise |
| C/D image install not in git merge alone | **NO-GO until snippets** | After git merge C/D, **must** apply Containerfile + build.sh snippets (playbook §4.3–4.4) |
| Pins unpinned on main | **NO-GO for publish** | `pins-static` FAIL (6× `/releases/latest`) until **A** merges |
| Harness present on main | **NO-GO for CI copy** | G not on main yet; use lane tip or merge G last |

**Integrator recommendation:** Proceed with **serial merge A→B→C→D→E→F→G** when ready; expect only **taskmaster** conflict resolution per lane if using full branch merges. Product path risk is **low** against current main; residual risk is **snippet apply** and **post-A rebuild**, not three-way skel wars.

---

## 1. Lane tips (fetched)

| Lane | Ref | Tip SHA | Merge-base w/ main | Product files* |
|---|---|---|---|---|
| A stabilize | `origin/lane/a-stabilize` | `94f08d6` | (probe merge-base) | 13 |
| B docs | `origin/lane/b-docs` | `fb3eb36` | | 20 |
| C assistant | `origin/lane/c-assistant` | `92a1a89` | | 46 |
| D duress | `origin/lane/d-duress` | `4bb5b55` | | 24 |
| E hyprland | `origin/lane/e-hyprland` | `935fd96` | | 19 |
| F cosmic | `origin/lane/f-cosmic` | `7b19270` | | 15 |
| G qa | `origin/lane/g-qa` | *(this branch tip)* | | 16+ |

\*Product = paths outside `planning/taskmaster/**` changed since merge-base.

Main note: director check-in `121ea50` **removed** accidental assistant KB files from a prior commit; C lane remains sole owner of `build_files/usr/share/hyprwave/assistant/**` and `apps/hyprwave-assistant/**`.

---

## 2. Pairwise `merge-tree` vs `origin/main`

| Lane | Product conflicts | Taskmaster conflicts | Verdict |
|---|---|---|---|
| A | **none** | `models/a/CURRENT_TASK.md` add/add | Product clean |
| B | **none** | `DIRECTOR_LOG`, `STATUS`, all `models/*/COMPLETED|CURRENT_TASK|WORK_LOG` add/add | Product clean; **prefer main** for director files, **prefer B** for docs product |
| C | **none** | `models/c/*` add/add | Product clean (additive app + share + snippets) |
| D | **none** | `models/d/CURRENT_TASK.md` | Product clean (additive duress packaging) |
| E | **none** | `models/e/*` content | Product clean (skel + integration docs) |
| F | **none** | `models/f/CURRENT_TASK.md` content | Product clean (vendor + iso notes + docs) |
| G | **none** | `models/g/CURRENT_TASK.md` content | Product clean (qa + g-qa only) |

### Hotspot classification (lane-only changes; main did not edit same product path)

| Path | Lanes | Risk | Resolution |
|---|---|---|---|
| `build_files/build.sh` | **A** (pins) | Medium (must land first) | Take A; later paste C/D snippets manually — do not reintroduce `/releases/latest` |
| `.github/workflows/build.yml`, `build-disk.yml` | **A** | Low–med | Take A pin_guards / matrix |
| `build_files/versions.env` | **A** | Low (new file) | Take A |
| `README.md` | **B** | Low | Prefer B install sections |
| `INSTALL.md`, `CHANGELOG.md`, `docs/**` | **B** | Low (new) | Take B |
| `apps/hyprwave-assistant/**`, share KB, desktop | **C** | Low (new) | Take C; then snippet apply |
| `build_files/duress/**`, `build-duress.sh` | **D** | Low (new) | Take D; then snippet apply; no `*.sha256` |
| `build_files/etc/skel/**` (hypr, waybar, yazi, ghostty, walker desktop) | **E** | Low vs main | Take E; Super+Shift+A remains **commented** until assistant in image |
| cosmic favorites, `is_dark`, `disk_config/iso-cosmic.toml` | **F** | Low | Take F |
| `planning/qa/**`, `planning/integration/g-qa/**` | **G** | Low | Take G last |

**No lane currently both-changes** `Containerfile` in git — install stages arrive via **snippets**.

---

## 3. Per-lane product path inventory (unique vs merge-base)

### 3.1 A — `a9c3ded`

- M `.github/workflows/build-disk.yml`, `build.yml`
- M `build_files/build.sh` (pin keys, no `/releases/latest` — **0** hits on lane tip)
- A `build_files/versions.env`
- A `planning/integration/a-stabilize/{BUMP,CI-MATRIX,COSIGN,FIRST-BOOT-CHECKLIST,RELEASE}.md`
- A `planning/integration/a-stabilize/scripts/{verify-pins,ghcr-pull-test}.sh`

**Post-merge QA:** `bash planning/qa/run-all.sh --only pins-static` → expect **PASS** (FAIL→PASS).

### 3.2 B — `f21b6c2`

- A `INSTALL.md`, `CHANGELOG.md`, full `docs/**` handbook set
- M `README.md`
- A `planning/integration/b-docs/**`

**Post-merge QA:** presence checks; no harness id for prose. Cross-link E keybinds after E merges.

### 3.3 C — `0c9838a`

- A entire `apps/hyprwave-assistant/**`
- A desktop + `build_files/usr/share/hyprwave/assistant/**`
- A `planning/integration/c-assistant/{Containerfile,build.sh}.snippet` + HANDOFF / RELEASE notes

**Post-merge (required):** apply snippets → image actually ships binary.  
**Post-merge QA:** `run-all.sh --only assistant` → WARN→PASS.

### 3.4 D — `b69a474`

- A `build_files/duress/**`, `build_files/build-duress.sh`
- A `planning/integration/d-duress/**` including `validate.sh`, FAQ, OPERATOR-RUNBOOK

**Post-merge (required):** snippets; keep PAM **off**.  
**Post-merge QA:** `validate.sh` + `run-all.sh --only duress-safety`.

### 3.5 E — `747b995`

- M skel hypr stack (`autostart`, `bindings`, idle/lock/paper, monitors, windowrules), waybar, yazi, ghostty, walker desktop
- A `planning/integration/e-hyprland/{AUTOSTART,KEYBIND-MAP,SESSION-SMOKE,THEME-SYMLINKS,HANDOFF,README}.md`
- Bind `Super+Shift+A` **commented** until C installed

**Post-merge QA:** `themes`, `no-wofi-swaybg`; manual SESSION-SMOKE.

### 3.6 F — `799d952`

- M cosmic favorites; A `CosmicTheme.Mode/v1/is_dark`; M `disk_config/iso-cosmic.toml`
- A integration docs + `check-vendor-paths.sh`, THEME-COSMIC-MATRIX

**Post-merge QA:** themes still green; COSMIC SESSION-SMOKE / vendor script optional.

### 3.7 G — (this branch)

- A `planning/qa/**` harness + `probe-merge-conflicts.sh` + `ci-snippet.yml`
- A `planning/integration/g-qa/**` playbook, smoke matrix, residuals, this dry-run

**Post-merge QA:** full `run-all.sh` on integrated tree.

---

## 4. Serial-merge caution (beyond pairwise)

Pairwise probes are vs **today’s main**. After A lands:

1. **build.sh** is pinned — C/D snippet paste must not reintroduce floating URLs.  
2. B’s README should not drop A release/pin notes if both touch (B currently owns README product edits; A does not).  
3. E does not rewrite build.sh; F does not rewrite shared pin blocks.  
4. Taskmaster files will keep conflicting — use strategy: **never merge model CURRENT_TASK as product**; consider path-level checkout:
   ```bash
   git checkout --ours planning/taskmaster/STATUS.md   # or theirs — Director owns main
   git checkout origin/lane/c-assistant -- apps/hyprwave-assistant planning/integration/c-assistant
   ```
5. Re-run probe after each merge:
   ```bash
   bash planning/qa/probe-merge-conflicts.sh --base HEAD --lanes e-hyprland,f-cosmic,g-qa --product-only
   ```

---

## 5. Suggested integration day order (unchanged)

See `MERGE-PLAYBOOK.md`. Minimum host gates:

| Step | Merge | Host gate |
|---|---|---|
| 0 | baseline | `run-all.sh` (expect pin FAIL) + `probe-merge-conflicts.sh --product-only` |
| 1 | A | `--only pins-static` PASS |
| 2 | B | INSTALL/CHANGELOG present |
| 3 | C + snippets | `--only assistant` PASS |
| 4 | D + snippets | `--only duress-safety` PASS; `validate.sh` |
| 5 | E | `--only themes,no-wofi-swaybg` |
| 6 | F | themes; vendor paths |
| 7 | G | full `run-all.sh` RESULT OK |
| 8 | publish | SMOKE-MATRIX §9 minimum green |

---

## 6. Probe command cheatsheet

```bash
# Full report (includes taskmaster CONFLICT lines)
bash planning/qa/probe-merge-conflicts.sh

# Integrator-focused product noise filter
bash planning/qa/probe-merge-conflicts.sh --product-only

# Single lane
bash planning/qa/probe-merge-conflicts.sh --lanes a-stabilize --product-only

# CI-style fail if product conflicts (still reports taskmaster if not filtered)
bash planning/qa/probe-merge-conflicts.sh --product-only --fail-on-conflict
```

**Not** registered in `run-all.sh` by default: merge-tree is an **integration-time** advisory, not a packaging invariant of the checked-out tree. See `planning/qa/README.md`.

---

## 7. What G will not do

- Merge any `lane/*` into `main`
- Apply C/D snippets to `build.sh` / `Containerfile`
- Edit exclusive A–F product paths
