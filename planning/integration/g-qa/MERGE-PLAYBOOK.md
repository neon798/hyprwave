# Merge playbook — seven-lane integration (A→G)

**Owner:** Model G (QA / integration prep) — this document only; **do not** merge lanes from the G agent.  
**Audience:** Director / human integrator performing a serial morning merge onto `main`.  
**Prerequisite:** Each `lane/*` has been pushed; Wave 1 Done criteria met (or residuals listed).

---

## 1. Goals

1. Land product + packaging work **without losing pins, docs, or OFF-by-default duress**.
2. Apply C/D **snippets** deliberately (they do not auto-merge into `build.sh`).
3. Run host QA (`planning/qa/run-all.sh`) after each major merge cluster.
4. Never force-push `main`. Never enable `pam_duress` in default image PAM stacks.

---

## 2. Exact merge order

| Step | Branch | Role | Why this order |
|---|---|---|---|
| 0 | (prep) | Clean tree, backup tag | Recoverable baseline |
| 1 | `lane/a-stabilize` | Pins, versions.env, CI gates | Pins must land before any rebuild/smoke that downloads companions |
| 2 | `lane/b-docs` | INSTALL/CHANGELOG/docs | Docs after pins so URLs/versions match; low code risk |
| 3 | `lane/c-assistant` | Go app + data + snippets | Product app; needs Containerfile/build.sh **snippet apply** (step 3b) |
| 4 | `lane/d-duress` | Duress packaging OFF by default | Independent of C; **snippet apply** (step 4b); validate before next |
| 5 | `lane/e-hyprland` | Hyprland skel UX | Touches skel; after C handoff notes for Super+Shift+A bind |
| 6 | `lane/f-cosmic` | COSMIC vendor defaults | Parallel-safe with E but after shared build.sh settles |
| 7 | `lane/g-qa` | QA harness + this playbook | Last so checks see full tree; no product code |

**Do not** merge G first and “hope” — G is validation glue.  
**Do not** merge C/D without applying snippets (dormant files alone do not ship into the image).

---

## 3. Prep (step 0)

```bash
git fetch origin
git checkout main
git pull --ff-only origin main
git status   # must be clean

# Recoverable tag before integration day
git tag -a "pre-integration-$(date -u +%Y%m%d)" -m "Before A–G lane merge"
# optional: git push origin tag pre-integration-YYYYMMDD

# Baseline QA on main (expect pin FAILs until A lands; WARNs for C/D)
bash planning/qa/run-all.sh || true
```

Record in a log: date, integrator name, base `main` SHA.

---

## 4. Per-lane merge recipe

Use **merge commits** (not squash) for auditability of lane boundaries, unless team policy says otherwise.

```bash
# Template for each step N:
git checkout main
git merge --no-ff origin/lane/<name> -m "merge: lane/<name> into main (Wave 1)"
# resolve conflicts (see §5)
bash planning/qa/run-all.sh   # or subset — see §6
```

### 4.1 Model A — `lane/a-stabilize`

**Expect:**

- `build_files/versions.env`
- Pin edits in `build_files/build.sh` (source env + sha256 verify)
- `planning/integration/a-stabilize/**` (BUMP, RELEASE, FIRST-BOOT, verify-pins.sh)
- Workflow greps / static CI gates

**Post-merge gate:**

```bash
grep -nE '/releases/latest' build_files/build.sh && exit 1 || true
test -f build_files/versions.env
bash planning/qa/run-all.sh --only pins-static
# optional network:
# bash planning/integration/a-stabilize/scripts/verify-pins.sh
```

### 4.2 Model B — `lane/b-docs`

**Expect:** `INSTALL.md`, `CHANGELOG.md`, `docs/**`, maybe `planning/integration/b-docs/README-sections.md`.

**Conflict hotspot:** `README.md` — prefer B’s install sections; keep A’s pin/release notes if both touched. If B shipped sections only under `planning/integration/b-docs/`, **manually apply** them to `README.md` here (do not drop).

**Post-merge gate:** files exist; skim install paths for both `hyprwave` and `hyprwave-cosmic`.

### 4.3 Model C — `lane/c-assistant` + snippet apply

**Git merge first** (brings `apps/hyprwave-assistant/**`, share data, desktop file, snippets).

#### 4.3b Snippet apply (required)

1. Open `planning/integration/c-assistant/Containerfile.snippet`  
   - Add **assistant-builder** stage (static-ish binary, `-trimpath`, version ldflags).  
   - `COPY --from=assistant-builder ... /usr/bin/hyprwave-assistant` in the final image stage.  
   - Do **not** drop existing `hyprbuilder` / cosmic stage aliases.

2. Open `planning/integration/c-assistant/build.sh.snippet`  
   - Paste into `build_files/build.sh` **after package installs**, **before** COPR disable / final cleanup.  
   - Safe for both `DE=hyprland` and `DE=cosmic` (shared section).

3. Read `planning/integration/c-assistant/HANDOFF-WAVE2.md` (or `HANDOFF.md`)  
   - Super+Shift+A keybind line is **skel-owned** → apply when merging E, or edit skel now if E not ready:  
     only the **single bind line** from handoff; do not rewrite bindings wholesale.

4. Optional README blurb from `README-blurb.md` → Model B/README.

**Post-merge gate:**

```bash
bash planning/qa/run-all.sh --only assistant
cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .
```

### 4.4 Model D — `lane/d-duress` + snippet apply

**Git merge first** (`build_files/duress/**`, `build_files/build-duress.sh`, integration docs).

#### 4.4b Snippet apply (required)

1. `planning/integration/d-duress/Containerfile.snippet`  
   - **duressbuilder** stage → install `pam_duress.so` / tools under a prefix.  
   - `COPY --from=duressbuilder` into final image.  
   - Confirm **no** live `/etc/pam.d` rewrite in the stage.

2. `planning/integration/d-duress/build.sh.snippet`  
   - Shared section: install templates, setup tool, docs, empty `/etc/duress.d`.  
   - **Must remain OFF by default** — no `auth … pam_duress` into system PAM.

3. Run lane validator:

```bash
bash planning/integration/d-duress/validate.sh
bash planning/qa/run-all.sh --only duress-safety
```

4. **Forbidden at merge time:** committing `*.sha256` signatures; enabling PAM “to test” on `main`.

### 4.5 Model E — `lane/e-hyprland`

**Expect:** skel under `build_files/etc/skel/.config/{hypr,waybar,walker,mako,ghostty,yazi,…}`, plus  
`planning/integration/e-hyprland/{AUTOSTART,KEYBIND-MAP,SESSION-SMOKE}.md`.

**Apply C keybind** if not already applied (Super+Shift+A).  
**Conflict hotspot:** any skel file also touched experimentally on main — prefer E for UX, keep C’s single bind.

**Post-merge gate:**

```bash
bash planning/qa/run-all.sh --only themes,no-wofi-swaybg
# manual: planning/integration/e-hyprland/SESSION-SMOKE.md
```

### 4.6 Model F — `lane/f-cosmic`

**Expect:** `build_files/usr/share/cosmic/**`, maybe `disk_config/iso-cosmic.toml` comments,  
`planning/integration/f-cosmic/{VENDOR-INVENTORY,SESSION-SMOKE,GREETER}.md`.

**Conflict hotspot:** `build_files/build.sh` **cosmic)** case only — prefer F for declutter/vendor copy; do not revert A pins or C/D snippets in shared sections.

**Post-merge gate:** vendor inventory vs tree; wallpaper paths exist; smoke doc ready for VM.

### 4.7 Model G — `lane/g-qa`

**Expect:** `planning/qa/**`, `planning/integration/g-qa/**` only.

```bash
git merge --no-ff origin/lane/g-qa -m "merge: lane/g-qa QA harness + merge playbook"
bash planning/qa/run-all.sh
```

---

## 5. Conflict hotspots (cheatsheet)

| Path | Lanes | Resolution rule |
|---|---|---|
| `build_files/build.sh` | A, C†, D†, F | A owns pin blocks; C/D **paste snippets** once; F only `cosmic)` arm; never delete COPR enable/disable pairs |
| `Containerfile` | A?, C†, D† | Keep multi-stage graph; add builder stages as additive; final `FROM de-${DE}` preserved |
| `README.md` | B (primary), A/C notes | B prose wins; keep accurate image names + dual variant |
| `.github/workflows/*` | A | Keep pin grep / QA job; don’t drop matrix for cosmic |
| `build_files/etc/skel/**` | E (primary), C handoff bind | E structure; add Super+Shift+A from C handoff |
| `build_files/versions.env` | A only | Never empty; never `/releases/latest` URLs |
| `build_files/duress/**` | D only | No `*.sha256`; ENABLE remains operator-driven |
| `apps/hyprwave-assistant/**` | C only | Don’t “clean up” tests to silence CI |

† Snippet apply is a **manual edit after git merge**, not a pure git conflict.

---

## 6. QA gates between merges

### 6.0 Pre-merge baseline (always)

```bash
git fetch origin
bash planning/qa/run-all.sh || true   # record exit + summary
# Optional multi-ref residual signal (soft-WARN if a lane ref not fetched):
bash planning/qa/run-all.sh --only lane-artifacts || true
```

Record: date, `main` SHA, harness RESULT, and which checks FAIL/WARN.

### 6.1 Minimum gates after each lane

| After | Minimum harness | Extra |
|---|---|---|
| A | `--only pins-static` | `verify-pins.sh` if network OK |
| B | (docs presence) | — |
| C + snippets | `--only assistant` | `go test` / `go build` |
| D + snippets | `--only duress-safety` | `validate.sh` |
| E | `--only themes,no-wofi-swaybg` | SESSION-SMOKE (manual) |
| F | themes still green | COSMIC SESSION-SMOKE (manual) |
| G / final | `run-all.sh` full | `just build` + `just build-cosmic` if resources allow |

### 6.2 Expected harness flips (FAIL/WARN → PASS)

| Event | Check | Typical before | Expected after |
|---|---|---|---|
| Merge A | `pins-static` | **FAIL** (`/releases/latest` in `build.sh`; missing `versions.env` WARN) | **PASS** (no latest; keys + sha shape OK) |
| Merge C + apply snippets | `assistant` | **WARN** soft-skip (no `apps/hyprwave-assistant`) | **PASS** (`go test ./...`) |
| Merge D + apply snippets | `duress-safety` | **WARN** soft-skip (no packaging / validate) | **PASS** (`validate.sh` green; no `*.sha256`) |
| Merge E | `themes`, `no-wofi-swaybg` | usually already **PASS** on main | still **PASS** (regression guard) |
| Merge F | themes / cosmic paths | PASS | PASS; manual COSMIC smoke |
| Merge G | harness available on main | N/A (scripts absent) | full `run-all.sh` RESULT OK when A–D done |
| `git fetch` lane tips | `lane-artifacts` | **WARN** per missing `origin/lane/*` | **PASS** paths when ref present; **FAIL** only if ref exists but expected path missing |

If a flip does **not** occur, stop the merge train and fix before the next lane (especially A pins and D validate).

### 6.3 Post-merge closeout

1. Full harness: `bash planning/qa/run-all.sh` → RESULT OK  
2. Update `planning/integration/g-qa/ENDPOINT-RESIDUALS.md` rows to **met on main**  
3. CI: copy `planning/qa/ci-snippet.yml` job into workflows (A/Director)  
4. Tag `post-integration-YYYYMMDD`

---

## 7. Image build & publish (integrator, not G)

```bash
just lint
just build
just build-cosmic
# optional disk:
# just build-qcow2
# just build-qcow2  # cosmic via IMAGE / DE as documented in Justfile
```

Publish/sign per `planning/integration/a-stabilize/RELEASE.md`.  
First-boot: `FIRST-BOOT-CHECKLIST.md` + `planning/integration/g-qa/SMOKE-MATRIX.md`.

---

## 8. Rollback

```bash
# Hard stop: return main to pre-integration tag (coordinator only)
git checkout main
git reset --hard pre-integration-YYYYMMDD
# If already pushed: prefer revert merges, not history rewrite
git revert -m 1 <merge_commit_sha>   # per bad merge, newest first
```

Do **not** `push --force` to `main` unless an explicit incident process says so.

---

## 9. Done definition for integration day

- [ ] Order A→B→C→D→E→F→G followed (or documented intentional swap with residual)
- [ ] C and D snippets applied; image would install assistant + duress **assets**
- [ ] Duress PAM still **disabled** by default
- [ ] `bash planning/qa/run-all.sh` → RESULT OK (or listed residuals)
- [ ] Smoke matrix row owners assigned for VM pass
- [ ] Tag `post-integration-YYYYMMDD` on green `main`

---

## 10. What Model G will not do

- Merge other lanes from `lane/g-qa`
- Implement Assistant/Duress/desktop product features
- Edit exclusive paths of A–F outside this playbook’s **instructions**
