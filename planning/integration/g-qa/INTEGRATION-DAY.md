# Integration day — master runbook (human / Director)

**Audience:** The person who merges Wave 1 lanes onto `main` and decides GHCR publish.  
**Owner of this doc:** Model G (prep only). **Model G does not merge** product lanes.  
**When:** After A–G Wave 1 tips are pushed and pre-merge dry-run is green.

### Related documents (read these; do not fork criteria)

| Doc | Role |
|---|---|
| [MERGE-PLAYBOOK.md](./MERGE-PLAYBOOK.md) | Order, hotspots, snippet apply detail, rollback |
| [PRE-MERGE-DRY-RUN.md](./PRE-MERGE-DRY-RUN.md) | Pairwise conflict probe narrative + go/no-go |
| [SMOKE-MATRIX.md](./SMOKE-MATRIX.md) | Build/session smokes; **§9 = GHCR publish hard gates** |
| [ENDPOINT-RESIDUALS.md](./ENDPOINT-RESIDUALS.md) | Program closeout tracker (update after merges) |
| [PROGRAM-CLOSEOUT.md](./PROGRAM-CLOSEOUT.md) | ENDPOINT 1–10 → exact verify commands for `PROGRAM_COMPLETE` |
| [../../qa/README.md](../../qa/README.md) | Host harness usage + exit codes |
| [../a-stabilize/MERGE-READY.md](../a-stabilize/MERGE-READY.md) | A pin/CI freeze gate (when A merged) |
| [../a-stabilize/RELEASE.md](../a-stabilize/RELEASE.md) · [COSIGN.md](../a-stabilize/COSIGN.md) | Publish/sign |
| [../a-stabilize/FIRST-BOOT-CHECKLIST.md](../a-stabilize/FIRST-BOOT-CHECKLIST.md) | First-boot log |
| [../b-docs/POST-MERGE-DOC-FLIP.md](../b-docs/POST-MERGE-DOC-FLIP.md) | Docs post-merge (when B present) |
| [../c-assistant/HANDOFF.md](../c-assistant/HANDOFF.md) · [HANDOFF-WAVE2.md](../c-assistant/HANDOFF-WAVE2.md) | Snippet + bind handoff |
| [../d-duress/INTEGRATOR-CHECKLIST.md](../d-duress/INTEGRATOR-CHECKLIST.md) | Duress merge freeze (PAM off) |
| [../e-hyprland/INTEGRATION-DAY.md](../e-hyprland/INTEGRATION-DAY.md) | Hyprland VM operator card |
| [../f-cosmic/INTEGRATOR-CHECKLIST.md](../f-cosmic/INTEGRATOR-CHECKLIST.md) | COSMIC freeze + vendor gate |

Paths under `planning/integration/{a–f}-*/` exist on those **lanes** until merged; if missing on current tree, open from `origin/lane/*`.

---

## 0. Non-negotiables (abort if violated)

| Rule | Abort if… |
|---|---|
| No force-push `main` | Anyone proposes `push --force` to main |
| No default duress PAM | Snippet or merge enables `pam_duress` in live `/etc/pam.d` image config |
| No floating pins after A | Any reintroduction of `/releases/latest` in `build.sh` / `versions.env` |
| No silent secret use | CI/publish needs undeclared secrets beyond existing SIGNING |
| Stop on unexplained product conflict | Product path conflict not explained by playbook hotspot table |

---

## 1. Time-boxed schedule (≈ half day)

| Slot | Clock | Activity |
|---|---|---|
| T0 | 0:00–0:20 | Prep (§2): fetch, tag, baseline probe + harness |
| T1 | 0:20–0:50 | Merge **A**; pins gate |
| T2 | 0:50–1:10 | Merge **B**; docs presence |
| T3 | 1:10–1:50 | Merge **C** + **snippet apply**; assistant tests |
| T4 | 1:50–2:30 | Merge **D** + **snippet apply**; validate |
| T5 | 2:30–3:00 | Merge **E**; themes / no-wofi |
| T6 | 3:00–3:20 | Merge **F**; vendor check if present |
| T7 | 3:20–3:40 | Merge **G**; full `run-all.sh` |
| T8 | 3:40–5:00+ | Images `just build` / `just build-cosmic`; VM smokes; GHCR decision (§8) |

Slip is fine; **do not skip gates** to “make the slot.”

---

## 2. Prep (T0) — do not merge yet

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
git status   # must be clean

# Recoverable tag
DAY=$(date -u +%Y%m%d)
git tag -a "pre-integration-${DAY}" -m "Before A–G lane merge"
# optional: git push origin "pre-integration-${DAY}"

# Record baseline SHAs
git rev-parse --short origin/main
for L in a-stabilize b-docs c-assistant d-duress e-hyprland f-cosmic g-qa; do
  git rev-parse --short origin/lane/$L
done

# Product conflict probe (expect taskmaster noise; product should be clean)
bash planning/qa/probe-merge-conflicts.sh --product-only || true
# If probe script not on main yet, run from G lane worktree or merge G last only after product.

# Host harness if present (else skip until G/A partial)
test -f planning/qa/run-all.sh && bash planning/qa/run-all.sh || true
```

**Fill log:**

```
date_utc:
integrator:
main_sha_before:
pre_integration_tag:
probe_product: PASS|FAIL
harness_baseline: PASS|FAIL|SKIP (note pin FAIL expected pre-A)
```

**Go / no-go after T0**

| Check | Go if |
|---|---|
| All seven `origin/lane/*` tips exist | yes |
| `probe-merge-conflicts.sh --product-only` clean (or documented exception) | yes |
| Tree clean; tag created | yes |

If product conflicts appear, **stop** and resolve on lanes before merging (see PRE-MERGE-DRY-RUN).

---

## 3. Conflict policy (every merge)

### 3.1 Product paths

| Path class | Prefer |
|---|---|
| `build_files/versions.env`, pin block in `build.sh`, pin CI | **A** |
| `README.md`, `INSTALL.md`, `CHANGELOG.md`, `docs/**` | **B** (keep A release accuracy) |
| `apps/hyprwave-assistant/**`, assistant share data | **C** |
| `build_files/duress/**`, `build-duress.sh` | **D** |
| `build_files/etc/skel/**` Hyprland UX | **E** (+ C bind when enabling assistant) |
| `build_files/usr/share/cosmic/**`, `iso-cosmic.toml` | **F** |
| `planning/qa/**`, `planning/integration/g-qa/**` | **G** |

### 3.2 Taskmaster paths (`planning/taskmaster/**`)

These **will** conflict (director CURRENT_TASK vs lane logs). They are **not** product.

| Strategy | Action |
|---|---|
| STATUS / DIRECTOR_LOG | Prefer **main** (Director) after merge, then Director rewrites |
| `models/<letter>/*` for the lane being merged | Prefer **that lane** tip for COMPLETED/WORK_LOG/IDENTITY; CURRENT_TASK may be set DONE on lane |
| Never block ship on CURRENT_TASK text | Resolve and continue |

```bash
# Example after a conflicted merge:
git status
# For product: fix real files per §3.1
# For taskmaster noise:
git checkout --ours planning/taskmaster/STATUS.md   # or explicit Director edit
git checkout origin/lane/<name> -- planning/taskmaster/models/<x>/WORK_LOG.md \
  planning/taskmaster/models/<x>/COMPLETED.md
```

### 3.3 Snippets are not git merges

C and D ship **snippet files**. After `git merge`, you must **paste** into `Containerfile` / `build_files/build.sh`. Dormant trees alone do **not** install into the image.

---

## 4. Serial merge procedure (T1–T7)

Template for each step:

```bash
git checkout main
git merge --no-ff origin/lane/<name> -m "merge: lane/<name> into main (Wave 1)"
# resolve conflicts per §3
# optional: re-probe remaining lanes
bash planning/qa/probe-merge-conflicts.sh --product-only --base HEAD --lanes <remaining> || true
```

### T1 — A `lane/a-stabilize`

**Lane card:** [MERGE-READY.md](../a-stabilize/MERGE-READY.md)

```bash
git merge --no-ff origin/lane/a-stabilize -m "merge: lane/a-stabilize into main (Wave 1)"
# resolve; keep A pin block
grep -nE '/releases/latest' build_files/build.sh && exit 1 || true
test -f build_files/versions.env
bash planning/qa/run-all.sh --only pins-static   # expect PASS
# optional network:
# bash planning/integration/a-stabilize/scripts/verify-pins.sh
```

| Expect | Before A | After A |
|---|---|---|
| `pins-static` | FAIL | **PASS** |

**Abort if:** pins still FAIL; pin_guards removed from workflows.

---

### T2 — B `lane/b-docs`

**Lane card:** [POST-MERGE-DOC-FLIP.md](../b-docs/POST-MERGE-DOC-FLIP.md) (when present)

```bash
git merge --no-ff origin/lane/b-docs -m "merge: lane/b-docs into main (Wave 1)"
test -f INSTALL.md && test -f CHANGELOG.md && test -d docs
# Apply README sections from planning/integration/b-docs/ if B kept them separate
```

**Abort if:** INSTALL missing both variants; docs contradict pinned URLs from A.

---

### T3 — C `lane/c-assistant` + snippets

**Lane cards:** [HANDOFF.md](../c-assistant/HANDOFF.md), snippets in `planning/integration/c-assistant/`

```bash
git merge --no-ff origin/lane/c-assistant -m "merge: lane/c-assistant into main (Wave 1)"
```

**3b — Snippet apply (required)**

1. `planning/integration/c-assistant/Containerfile.snippet` → additive builder stage + `COPY` into final image; keep `de-${DE}` / hyprbuilder graph.  
2. `planning/integration/c-assistant/build.sh.snippet` → shared section after installs, before COPR disable.  
3. Super+Shift+A: only when ready (E may leave bind **commented** until binary exists) — single bind line from HANDOFF.  
4. Optional: `README-blurb.md` → README via B policy.

```bash
bash planning/qa/run-all.sh --only assistant
cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .
# optional: bash planning/integration/c-assistant/smoke-host.sh
```

| Expect | Before | After snippets + tree |
|---|---|---|
| `assistant` | WARN | **PASS** |

**Abort if:** snippets not applied but release notes claim assistant in image; `go test` fails.

---

### T4 — D `lane/d-duress` + snippets

**Lane card:** [INTEGRATOR-CHECKLIST.md](../d-duress/INTEGRATOR-CHECKLIST.md)

```bash
git merge --no-ff origin/lane/d-duress -m "merge: lane/d-duress into main (Wave 1)"
```

**4b — Snippet apply (required)**

1. Duress builder stage + `COPY` from `Containerfile.snippet` — **no** live PAM rewrite.  
2. `build.sh.snippet` installs assets only; empty `/etc/duress.d` OK.  
3. Confirm no `*.sha256` committed.

```bash
find build_files/duress planning/integration/d-duress -name '*.sha256' | tee /tmp/duress-sha.txt
test ! -s /tmp/duress-sha.txt
bash planning/integration/d-duress/validate.sh
bash planning/qa/run-all.sh --only duress-safety
# optional: bash planning/integration/d-duress/snippet-selftest.sh
```

| Expect | Before | After |
|---|---|---|
| `duress-safety` | WARN | **PASS** |

**Abort if:** PAM enabled by default; signatures present; validate fails.

---

### T5 — E `lane/e-hyprland`

**Lane card:** [INTEGRATION-DAY.md](../e-hyprland/INTEGRATION-DAY.md) (VM log) · [SESSION-SMOKE.md](../e-hyprland/SESSION-SMOKE.md)

```bash
git merge --no-ff origin/lane/e-hyprland -m "merge: lane/e-hyprland into main (Wave 1)"
bash planning/qa/run-all.sh --only themes,no-wofi-swaybg
# Uncomment Super+Shift+A only if C binary will ship in next image build
```

**Abort if:** wofi/swaybg reintroduced; themes FAIL.

---

### T6 — F `lane/f-cosmic`

**Lane card:** [INTEGRATOR-CHECKLIST.md](../f-cosmic/INTEGRATOR-CHECKLIST.md)

```bash
git merge --no-ff origin/lane/f-cosmic -m "merge: lane/f-cosmic into main (Wave 1)"
# if present:
test -x planning/integration/f-cosmic/check-vendor-paths.sh && \
  bash planning/integration/f-cosmic/check-vendor-paths.sh
bash planning/qa/run-all.sh --only themes
```

**Abort if:** cosmic-store reintroduced as default dock store; vendor check fails; Mode dark dropped.

---

### T7 — G `lane/g-qa`

```bash
git merge --no-ff origin/lane/g-qa -m "merge: lane/g-qa into main (Wave 1)"
bash planning/qa/run-all.sh
# expect RESULT OK (no FAIL). WARN only if intentional residual.
bash planning/qa/probe-merge-conflicts.sh --product-only || true
```

**Abort if:** harness RESULT FAIL after all product merges + snippets.

---

## 5. After-each-lane command cheat sheet

| After | Minimum | Full optional |
|---|---|---|
| any | `git status` clean of conflict markers | `probe-merge-conflicts.sh --product-only --base HEAD` |
| A | `run-all.sh --only pins-static` | `verify-pins.sh` |
| B | file presence INSTALL/CHANGELOG/docs | accuracy skim |
| C+snippets | `run-all.sh --only assistant` | `go test` / `smoke-host.sh` |
| D+snippets | `validate.sh` + `duress-safety` | `snippet-selftest.sh` |
| E | `themes,no-wofi-swaybg` | E INTEGRATION-DAY VM card |
| F | `themes` + vendor script | F SESSION-SMOKE |
| G / final | `run-all.sh` full | SMOKE-MATRIX §9 |

Harness exit codes: **0** = no FAIL (WARN OK); **1** = FAIL; **2** = misuse. See `planning/qa/README.md`.

---

## 6. Image build & session smoke (T8)

```bash
just lint
just build
just build-cosmic
# optional disks:
# just build-qcow2
```

Then:

1. First boot: [FIRST-BOOT-CHECKLIST.md](../a-stabilize/FIRST-BOOT-CHECKLIST.md)  
2. Hyprland VM: [e-hyprland/INTEGRATION-DAY.md](../e-hyprland/INTEGRATION-DAY.md) / SESSION-SMOKE  
3. COSMIC VM: [f-cosmic/SESSION-SMOKE.md](../f-cosmic/SESSION-SMOKE.md)  
4. Cross-cutting: SMOKE-MATRIX §5 (assistant offline, duress assets present, PAM off)

---

## 7. Update residuals

After the train (or each major step), edit [ENDPOINT-RESIDUALS.md](./ENDPOINT-RESIDUALS.md):

- Flip rows from **met on lane** → **met on main** when true.  
- List any deferred items with owners.  
- Director closes program only when ENDPOINT process criteria + residuals empty/deferred.

---

## 8. GHCR publish go/no-go (SMOKE-MATRIX §9)

**Do not publish** “Wave 1 integrated” until hard gates pass:

| # | Gate | Proof |
|---|---|---|
| P1 | Host harness clean | `bash planning/qa/run-all.sh` → RESULT OK |
| P2 | Pins fail-closed | no `/releases/latest`; pins-static PASS |
| P3 | Hyprland image | `just build` green |
| P4 | COSMIC image | `just build-cosmic` green |
| P5 | Duress OFF + safe | duress-safety PASS; no default pam_duress; no `*.sha256` |
| P6 | Assistant if claimed | binary path + tests green |
| P7 | No product conflict markers | clean tree; probe was product-clean pre-merge |

Soft gates (S1–S5) may residual — see SMOKE-MATRIX §9.2.

Publish/sign: [RELEASE.md](../a-stabilize/RELEASE.md) + [COSIGN.md](../a-stabilize/COSIGN.md).  
Tag: `post-integration-YYYYMMDD` on green `main`.

---

## 9. Abort & rollback

**Abort mid-train** if any §0 rule trips or a hard gate fails twice after honest fix attempts.

```bash
# Local unpushed disaster only — coordinator policy:
git checkout main
git reset --hard pre-integration-YYYYMMDD

# If merges already pushed: revert newest first (no force-push)
git revert -m 1 <merge_commit_sha>
```

---

## 10. Integrator day log template

```
Integration day log
date_utc:
integrator:
pre_tag:
main_before:
main_after:

A: merge_sha=  pins=PASS|FAIL
B: merge_sha=  docs=OK|FAIL
C: merge_sha=  snippets=YES|NO  assistant=PASS|FAIL
D: merge_sha=  snippets=YES|NO  validate=PASS|FAIL  pam_default=OFF|ON
E: merge_sha=  themes=PASS|FAIL
F: merge_sha=  vendor=PASS|FAIL|SKIP
G: merge_sha=  run_all=PASS|FAIL

just_build:
just_build_cosmic:
hyprland_smoke:
cosmic_smoke:
ghcr_publish: GO|NO-GO
residuals:
signer:
```

---

## 11. What this runbook does **not** authorize

- Model G (or any automation on `lane/g-qa`) merging A–F into main  
- Enabling duress PAM in default images  
- Skipping snippet apply for C/D  
- Publishing to GHCR with harness FAIL or floating pins  

For deep per-lane detail, always prefer the lane’s own integrator checklist / INTEGRATION-DAY card linked above.
