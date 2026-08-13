# Program closeout matrix — ENDPOINT verification

**Audience:** Director / human integrator deciding `PROGRAM_COMPLETE`.  
**Owner:** Model G (matrix only). **Does not merge** product lanes.  
**Source:** `planning/taskmaster/ENDPOINT.md` § Product 1–10 + Process.  
**Inspection baseline (pre-merge):** `origin/main` @ `98fe075` (2026-08-07 UTC).  
**Post-merge refresh:** 2026-08-13 — Wave 1 on main; image builds **met** (CI `31662742064` + local + `check-image.sh --cosmic` PASS G-W3-001). **Open only:** VM qcow2 smokes + GHCR anonymous 403.

### Linked procedures

| Doc | Use when |
|---|---|
| [INTEGRATION-DAY.md](./INTEGRATION-DAY.md) | Day-of serial A→G merge + snippet apply |
| [ENDPOINT-RESIDUALS.md](./ENDPOINT-RESIDUALS.md) | Living open/lane/main status tracker |
| [SMOKE-MATRIX.md](./SMOKE-MATRIX.md) **§9** | Hard/soft gates before GHCR publish |
| [MERGE-PLAYBOOK.md](./MERGE-PLAYBOOK.md) | Conflict hotspots + rollback |
| [PRE-MERGE-DRY-RUN.md](./PRE-MERGE-DRY-RUN.md) | Pairwise product conflict probe |
| [../../qa/README.md](../../qa/README.md) | Host harness exit codes |

---

## 0. Pre-merge baseline (do not guess)

Recorded against **current main before** Wave 1 lane merge train:

| Fact | Evidence |
|---|---|
| Pins **fail** on main | `build_files/build.sh` has **6×** `/releases/latest`; no `build_files/versions.env` |
| Harness **absent** on main | no `planning/qa/run-all.sh` until G merges |
| Assistant **absent** on main | no `apps/hyprwave-assistant` |
| Duress packaging **absent** on main | no `build_files/duress` / validate |
| Docs handbook **absent** on main | no `INSTALL.md` / `CHANGELOG.md` / `docs/` |
| C/D need **snippet apply** after git merge | snippets live under `planning/integration/{c-assistant,d-duress}/` — image install is not automatic |
| Product pairwise merges | historically **product-clean** via `probe-merge-conflicts.sh --product-only` (taskmaster conflicts expected) |

**Implication:** Until A merges, `pins-static` FAIL is **expected**. Until C/D snippets land, assistant/duress image claims are **false** even if trees merge.

Lane tips at matrix authoring (refresh with `git fetch`):

| Lane | Tip (short) |
|---|---|
| a-stabilize | `0dbde46` |
| b-docs | `4ababf9` |
| c-assistant | `2dafc3b` |
| d-duress | `84371bb` |
| e-hyprland | `985b441` |
| f-cosmic | `a4cdb8a` |
| g-qa | (this branch) |

---

## 1. ENDPOINT § Product — verification matrix

Status column uses: **open** (not on main) · **met on lane** · **met on main** · **partial**.  
Update status after integration day; leave verify commands unchanged.

### Item 1 — Integrated main contains Wave 1+2 lanes

| Field | Value |
|---|---|
| **Status (pre-merge)** | **open** (all product lanes still lane-only or partial skel on main) |
| **Owner lanes** | A, B, C, D, E, F, G |
| **Verify (after serial merge)** | |
| | `git merge-base --is-ancestor origin/lane/a-stabilize HEAD` (repeat B–G or check path presence) |
| | `test -f build_files/versions.env` |
| | `test -f INSTALL.md && test -d docs` |
| | `test -d apps/hyprwave-assistant` |
| | `test -d build_files/duress` |
| | `test -f planning/qa/run-all.sh` |
| **Evidence** | INTEGRATION-DAY log; main contains product paths; no lost pin/docs per playbook |
| **Blocks PROGRAM_COMPLETE?** | **Yes** if any Wave 1 product lane intentionally in-scope is missing without residual |

### Item 2 — Hyprland image builds with pinned binaries

| Field | Value |
|---|---|
| **Status (pre-merge)** | **open** on main; **met on lane** A |
| **Owner lane** | A |
| **Verify** | |
| | `! grep -nE '/releases/latest' build_files/build.sh build_files/versions.env` |
| | `bash planning/qa/run-all.sh --only pins-static` → PASS |
| | `just build` → success + `bootc container lint` (CI or local) |
| | optional: `bash planning/integration/a-stabilize/scripts/verify-pins.sh` |
| **Evidence** | harness summary; CI log; image id |
| **Blocks PROGRAM_COMPLETE?** | **Yes** |

### Item 3 — COSMIC image builds with vendor defaults intact

| Field | Value |
|---|---|
| **Status (pre-merge)** | **partial** (cosmic path on main; F freeze on lane) |
| **Owner lane** | F (+ A CI matrix) |
| **Verify** | |
| | `just build-cosmic` → success |
| | `test -f build_files/usr/share/cosmic/com.system76.CosmicAppList/v1/favorites` |
| | `test -f build_files/usr/share/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark` (after F) |
| | if present: `bash planning/integration/f-cosmic/check-vendor-paths.sh` → 0 |
| | no default `cosmic-store` as sole app store story in favorites (FlatArcade present) |
| **Evidence** | build log; vendor script; F SESSION-SMOKE notes |
| **Blocks PROGRAM_COMPLETE?** | **Yes** for dual-variant claim |

### Item 4 — Assistant built into image (or gated); offline KB/catalog

| Field | Value |
|---|---|
| **Status (pre-merge)** | **open**; **met on lane** C (sources); image install **open** until snippets |
| **Owner lane** | C (+ E bind; integrator snippets) |
| **Verify** | |
| | `bash planning/qa/run-all.sh --only assistant` → PASS |
| | `cd apps/hyprwave-assistant && go test ./...` |
| | Containerfile / build.sh contain assistant install (snippet applied — grep binary path / stage) |
| | `test -f build_files/usr/share/hyprwave/assistant/catalog.toml` |
| | `test -d build_files/usr/share/hyprwave/assistant/kb` |
| | runtime (image/VM): `hyprwave-assistant` or desktop entry launches; offline KB works |
| | Super+Shift+A only if bind enabled post-C |
| **Evidence** | go test; image file list; smoke note |
| **Blocks PROGRAM_COMPLETE?** | **Yes** if assistant is in-scope for Wave 1; else residual “gated/not shipped” |

### Item 5 — Duress packaged, OFF by default; ENABLE; validate; no pre-signed scripts

| Field | Value |
|---|---|
| **Status (pre-merge)** | **open**; **met on lane** D |
| **Owner lane** | D (+ integrator snippets) |
| **Verify** | |
| | `bash planning/integration/d-duress/validate.sh` → green |
| | `bash planning/qa/run-all.sh --only duress-safety` → PASS |
| | `find build_files/duress planning/integration/d-duress -name '*.sha256' \| wc -l` → 0 |
| | `test -f build_files/duress/ENABLE.md` |
| | image/VM: assets present; **no** default `pam_duress` in shipped PAM stacks |
| **Evidence** | validate output; harness; pam inspection note |
| **Blocks PROGRAM_COMPLETE?** | **Yes** |

### Item 6 — Desktop (Hyprland skel) coherent

| Field | Value |
|---|---|
| **Status (pre-merge)** | **partial** (baseline on main; E polish **met on lane**) |
| **Owner lane** | E (+ B keybind docs) |
| **Verify** | |
| | `bash planning/qa/run-all.sh --only themes,no-wofi-swaybg` → PASS |
| | `test -f build_files/etc/skel/.config/hypr/autostart.conf` |
| | `grep -E 'walker|hyprpaper|waybar|mako' build_files/etc/skel/.config/hypr/autostart.conf` |
| | VM: E [INTEGRATION-DAY.md](../e-hyprland/INTEGRATION-DAY.md) / SESSION-SMOKE gates |
| | docs/keybinds (B) match KEYBIND-MAP (E) for shipped binds |
| **Evidence** | harness; VM smoke log |
| **Blocks PROGRAM_COMPLETE?** | **Yes** for Hyprland variant quality bar |

### Item 7 — COSMIC greeter/session on-brand; FlatArcade; no store regression

| Field | Value |
|---|---|
| **Status (pre-merge)** | **partial** / F **met on lane** for docs+delta |
| **Owner lane** | F |
| **Verify** | |
| | F [INTEGRATOR-CHECKLIST.md](../f-cosmic/INTEGRATOR-CHECKLIST.md) boxes |
| | [SESSION-SMOKE.md](../f-cosmic/SESSION-SMOKE.md) / GREETER.md executed on COSMIC image |
| | favorites include FlatArcade/Neonwolf/Ghostty story; not COSMIC store as default store |
| **Evidence** | checklist + VM log |
| **Blocks PROGRAM_COMPLETE?** | **Yes** for dual-variant claim (soft residual only if COSMIC deferred in STATUS) |

### Item 8 — Docs: INSTALL, CHANGELOG, troubleshooting, architecture, keybinds

| Field | Value |
|---|---|
| **Status (pre-merge)** | **open**; **met on lane** B |
| **Owner lane** | B |
| **Verify** | |
| | `test -f INSTALL.md && test -f CHANGELOG.md` |
| | `test -f docs/troubleshooting.md && test -f docs/architecture.md && test -f docs/keybinds.md` |
| | Skim accuracy vs tree after A–F (B POST-MERGE-DOC-FLIP if present) |
| | Install paths mention `hyprwave` and `hyprwave-cosmic` |
| **Evidence** | file list; accuracy notes |
| **Blocks PROGRAM_COMPLETE?** | **Yes** |

### Item 9 — QA automated packaging checks documented and runnable

| Field | Value |
|---|---|
| **Status (pre-merge)** | **open**; **met on lane** G |
| **Owner lane** | G |
| **Verify** | |
| | `bash planning/qa/run-all.sh` → **RESULT OK** (no FAIL) after integration |
| | `bash planning/qa/run-all.sh --list` shows pins-static, themes, no-wofi-swaybg, duress-safety, assistant, image, lane-artifacts |
| | `test -f planning/qa/ci-snippet.yml` |
| | `test -f planning/integration/g-qa/INTEGRATION-DAY.md` |
| | docs: `planning/qa/README.md` exit codes 0/1/2 |
| **Evidence** | harness summary paste; CI job optional |
| **Blocks PROGRAM_COMPLETE?** | **Yes** |

### Item 10 — Release path: GHCR notes, first-boot, no silent latest

| Field | Value |
|---|---|
| **Status (pre-merge)** | **open**; A docs **met on lane** |
| **Owner lane** | A (+ G smoke/publish gates) |
| **Verify** | |
| | `test -f planning/integration/a-stabilize/RELEASE.md` |
| | `test -f planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md` |
| | `test -f planning/integration/a-stabilize/COSIGN.md` (if signing claimed) |
| | SMOKE-MATRIX **§9** hard gates P1–P7 all checked |
| | no `/releases/latest` (item 2) |
| | optional: GHCR pull probe script from A |
| **Evidence** | publish log; digests; first-boot owner assigned |
| **Blocks PROGRAM_COMPLETE?** | **Yes** if release claimed; residual if “docs only, no public push yet” |

---

## 2. ENDPOINT § Process

| Criterion | Verify | Status (pre-merge) |
|---|---|---|
| Lanes A–G ownership clear | IDENTITY.md files under `planning/taskmaster/models/*` | **met** |
| Residuals listed | [ENDPOINT-RESIDUALS.md](./ENDPOINT-RESIDUALS.md) + this matrix | **met** (tracker exists; product still open) |
| `STATUS.md` → `PROGRAM_COMPLETE` | Director sets after items 1–10 true or deferred | **open** (Director only) |
| Non-goals not treated as blockers | duress PAM default, NVIDIA farm, theme rewrite, marketing site | **deferred** |

---

## 3. One-shot post-merge verification script (integrator)

Run on integrated `main` (after snippets):

```bash
set -euo pipefail
echo "== closeout host checks =="
bash planning/qa/run-all.sh
! grep -nE '/releases/latest' build_files/build.sh build_files/versions.env
test -f INSTALL.md && test -f CHANGELOG.md
test -d apps/hyprwave-assistant
test -d build_files/duress
bash planning/integration/d-duress/validate.sh
test -f planning/integration/a-stabilize/RELEASE.md
test -f planning/integration/g-qa/INTEGRATION-DAY.md
echo "Host path OK — still need just build / just build-cosmic / VM smokes / §9 checklist"
```

Then complete SMOKE-MATRIX §9 and fill INTEGRATION-DAY log template.

---

## 4. Decision rule for Director

```
IF all Product items 1–10 are met on main (or deferred with named residual in STATUS.md)
AND Process residuals empty or deferred
AND SMOKE-MATRIX §9 hard gates P1–P7 passed for any GHCR publish claim
THEN Director may set STATUS.md → PROGRAM_COMPLETE
ELSE keep status open and point at failing verify command above
```

Model G does **not** set `PROGRAM_COMPLETE`. Model G does **not** merge lanes.

---

## 5. Quick status scoreboard (edit after integration day)

| # | Item | Pre-merge | Post-merge (2026-08-13) | Verify owner |
|---|---|---|---|---|
| 1 | Integrated main | open | **met on main** | Integrator |
| 2 | Pins + hypr build | open / lane A | **met** (pins + local/CI image) | A / CI |
| 3 | COSMIC build | partial | **met** (local/CI image) | F / CI |
| 4 | Assistant | open / lane C | **met** (sources + image binary) | C + snippets |
| 5 | Duress OFF | open / lane D | **met** (validate + no pam_duress in image) | D + snippets |
| 6 | Hyprland desktop | partial | **partial** (image OK; **VM smoke open**) | E |
| 7 | COSMIC UX | partial | **partial** (image OK; **VM smoke open**) | F |
| 8 | Docs | open / lane B | **met on main** (accuracy polish OK) | B |
| 9 | QA harness | open / lane G | **met** (+ `check-image.sh`) | G |
| 10 | Release path | open / lane A | **partial** (CI green; **GHCR anon 403**; publish open) | A / Director |

### T8 residual (do not call “all T8 pending” or “image build pending”)

| Step | Status |
|---|---|
| Container image builds (CI + local) | **met** — CI `31662742064`; local hyprland + cosmic tags; `check-image.sh` / `--cosmic` PASS |
| Image content smoke (automated) | **met** — G-W2-001 / G-W3-001 |
| VM session smokes (qcow2) | **open** (human) |
| GHCR public pull / signed Wave-1 publish | **open** (anonymous 403) |
