# Model A Work Log

(append only)

## 2026-08-07 — A-W1-001

**status:** DONE  
**branch:** `lane/a-stabilize`  
**tip:** (see COMPLETED.md after push)

### Work done

- Confirmed Wave 1/2 base: `build.sh` sources `versions.env`, `verify_sha256` for Yazi/Neonwolf/FlatArcade, zero `releases/latest`.
- Enhanced `planning/integration/a-stabilize/scripts/verify-pins.sh`:
  - `--head` (default), `--checksum` / `--sha256`, `--light`, `--help`
  - Light mode skips Neonwolf AppImage; still HEAD-checks its URL
  - Documented usage in script header + `versions.env` comments
- CI `pin_guards` (`build.yml`): existing grep / bash -n / keys; now also `--head` + `--checksum --light`
- `BUMP.md`: full FlatArcade end-to-end worked example + rollback pointer
- `RELEASE.md`: when-to-bump policy table + image/pin rollback
- `FIRST-BOOT-CHECKLIST.md`: image digest fields + checksum row in log template; A-W1-001 filled log

### Validation

```
grep releases/latest build_files/build.sh → clean
bash …/verify-pins.sh → exit 0
bash …/verify-pins.sh --checksum --light → exit 0 (Yazi+FlatArcade sha256 OK)
shellcheck verify-pins.sh → clean
```

### Commits (this task)

1. `verify-pins: add --checksum/--light modes and document usage`
2. `CI: pin_guards also run light pin checksum verification`
3. `Docs: FlatArcade bump walkthrough, rollback, digest in first-boot log`
4. taskmaster status DONE + WORK_LOG/COMPLETED

### Notes for Director

- GHCR anonymous pull still FAIL (private/403) — tracked in RELEASE.md; not a pin code defect.
- Full Neonwolf `--checksum` (no --light) not required in CI; operators can run it pre-release.

## 2026-08-07 — A-W1-002

**status:** DONE  
**branch:** `lane/a-stabilize`  
**tip:** (see COMPLETED.md after push)

### Work done

- Audited `build.yml` / `build-disk.yml` dual-image matrix; wrote `CI-MATRIX.md`
  (job graph, image names, PR vs publish, gaps).
- Tightened CI:
  - `pin_guards`: assert `matrix.de: [hyprland, cosmic]` + disk `iso-cosmic.toml`
  - `build-disk.yml`: `verify-pins.sh --head` before BIB
  - pin_guards already runs on all PRs (documented)
- `COSIGN.md`: verify both images, digest path, failure modes, key rotation (no private keys)
- `RELEASE.md`: GHCR Settings → Public path, `ghcr-pull-test.sh`, private-registry contingency
- `scripts/ghcr-pull-test.sh`: empty authfile dual-image anonymous probe
- FIRST-BOOT GHCR section points at the probe

### Validation

```
token=$(printf '%s/%s' releases latest)
grep -nF "$token" build_files/build.sh versions.env → clean
bash …/verify-pins.sh --head → exit 0
bash …/ghcr-pull-test.sh → exit 1 (hyprwave unauthorized; cosmic may inspect — fail closed)
```

### Commits

1. `ci: dual DE matrix guard + disk verify-pins HEAD`
2. `docs(a-stabilize): CI matrix audit and cosign verify runbook`
3. `docs(a-stabilize): GHCR visibility path and anonymous pull probe`
4. taskmaster DONE + WORK_LOG/COMPLETED

### Notes for Director

- Maintainer still must flip GHCR packages Public (or document private PAT install).
- Disk workflow cannot `needs:` container build across workflows; operators publish images first.

## 2026-08-07 — A-W1-003

**status:** DONE  
**branch:** `lane/a-stabilize`  
**tip:** (see COMPLETED.md after push)

### Work done

- `MERGE-READY.md`: why A first, conflict risks, pin freeze table, container vs disk
  pin_guards agreement (light checksum intentional disk gap only), min green local+CI
- Re-ran `verify-pins.sh --head` and `--checksum --light` → exit 0
- Confirmed both workflows block floating-release token; disk adds cosmic matrix assert
- `versions.env` header → MERGE-READY / CI-MATRIX / COSIGN / verify + advisory scripts
- `scripts/check-upstream-pins.sh` advisory (all pins current vs GitHub latest)
- RELEASE + CI-MATRIX link MERGE-READY

### Validation

```
verify-pins --head → 0
verify-pins --checksum --light → 0
check-upstream-pins → 0 (yazi/neonwolf/flatarcade all current)
floating token grep → clean
```

### Commits

1. `docs(a-stabilize): MERGE-READY pre-merge pin freeze gate`
2. `pins: freeze comments + advisory check-upstream-pins.sh`
3. `ci/docs: disk cosmic matrix guard; link MERGE-READY`
4. taskmaster DONE + WORK_LOG/COMPLETED

### Notes for Director

- Lane A is merge-ready on pins/CI docs; GHCR public still maintainer action.
- Integrator: follow MERGE-READY minimum green before merge to main.

## 2026-08-07 — A-W1-003 reconfirm (Task Master still OPEN on main)

**status:** DONE (no new product work)  
**branch:** `lane/a-stabilize`

Re-synced `models/a` from `origin/main` which still listed A-W1-003 OPEN.
Re-validated all requirements already landed on this lane:

- MERGE-READY.md present
- verify-pins --head exit 0; --checksum --light exit 0
- build.yml + build-disk.yml both block floating-release token
- versions.env points at MERGE-READY / CI-MATRIX / COSIGN
- check-upstream-pins.sh present (advisory)

No invented follow-up work. Status remains DONE; idle for next OPEN task id.

## 2026-08-07 — A-W1-004

**status:** DONE  
**branch:** `lane/a-stabilize`

### Work done

- Added `INTEGRATION-DAY.md` one-page ordered merge/verify card
- Cross-links from MERGE-READY, RELEASE, versions.env
- Confirmed floating-release token clean; verify-pins --head exit 0

### Commits

1. `docs(a-stabilize): INTEGRATION-DAY one-page merge run sheet`
2. `docs(a-stabilize): cross-link INTEGRATION-DAY from pin freeze docs`
3. taskmaster DONE + WORK_LOG/COMPLETED

## 2026-08-07 — A-W1-004 reconfirm (main reissued OPEN)

**status:** DONE (no new product work)

Director reissued W1-004 after W1-003 completed. Lane already had:

- `INTEGRATION-DAY.md` (40b349f) with MERGE-READY/CI-MATRIX/COSIGN/BUMP links
- Cross-links in versions.env, MERGE-READY, RELEASE
- Floating-release token clean; tip 0dbde46 / COMPLETED 435c39b

No invented follow-up. Idle for next OPEN task id.

## 2026-08-07 — A-W1-HOLD heartbeat

**status:** OPEN (HOLD — not DONE)  
**branch:** `lane/a-stabilize` @ e405a70 / freeze tip A-W1-004 `435c39b`

Idle: no product work. Awaiting human/Director serial merge per INTEGRATION-DAY.
Exclusive paths frozen. Will not mark HOLD as DONE.

## 2026-08-13 — A-W2-001

**status:** DONE  
**branch:** `lane/a-stabilize`  
**HOLD:** cancelled (Director)

### Refresh

- `git fetch origin` + `git merge origin/main` (Wave 1 now on main)
- `git checkout origin/main -- planning/taskmaster/models/a/`

### Pin verify log

```
verify-pins.sh --head            exit 0  (4× HTTP 200)
verify-pins.sh --head --light    exit 0
verify-pins.sh --checksum --light exit 0  (Yazi + FlatArcade + SVG sha256)
check-upstream-pins.sh           current (yazi v26.5.6, neonwolf v152.0.1-3, flatarcade v0.1.0)
planning/qa/run-all.sh --only pins-static  RESULT: OK (11 PASS)
releases/latest in build.sh / versions.env  CLEAN
```

**Pins still current** — no `versions.env` tag bump; comment updated with 2026-08-13 verify date.

### GHCR / CI reality (docs)

- CI dual-image **build + push** on `77755f1` run `31662742064`
- Local: `localhost/hyprwave:latest` (9bc0e1e57d6b), `localhost/hyprwave-cosmic:latest` (189340691cc7)
- `ghcr-pull-test.sh --owner neon798` **exit 1**: hyprwave `unauthorized`; cosmic inspect OK
- **Do not claim public GHCR.** Next human step: Packages → `hyprwave` (then confirm both) → Public

### Dependabot (skipped)

Reviewed vs `origin/main`; all exclusive to `.github/workflows/*`. **Not landed** this cycle:

| Branch | Change | Why skip |
|--------|--------|----------|
| `actions/checkout-7.0.1` | checkout v6 → **v7** | major; not CI-safe without a green rebuild |
| `redhat-actions/push-to-registry-3` | push-to-registry v2 → **v3** | major; just-green push path |
| `docker/login-action-4.5.1` | 4.2.0 → 4.5.1 | patch, but no reason to touch login same day as 31662742064 |
| `docker/metadata-action-6.2.0` | 6.1.0 → 6.2.0 | minor; skip until isolated PR |
| `sigstore/cosign-installer-4.1.2` | 4.1.0 → 4.1.2 | patch; skip (still pins `cosign-release: v2.6.3`) |

### Docs

- `RELEASE.md` Wave 1 CI closeout + visibility next step
- `FIRST-BOOT-CHECKLIST.md` local images + 2026-08-13 probe log
- `COSIGN.md` verify blocked on hyprland unauthorized

### Commits

1. merge `origin/main` into lane
2. pin comment + release/first-boot/cosign closeout
3. taskmaster DONE + WORK_LOG/COMPLETED

## 2026-08-13 — A-W2-001 reconfirm (main still OPEN)

**status:** DONE (no new product work)

Director copy on `origin/main` still listed A-W2-001 OPEN. Re-synced models/a,
merged latest main (G-W2-003 / T8 only), re-ran gates:

```
verify-pins.sh --head --light     exit 0  (4× HTTP 200)
verify-pins.sh --checksum --light exit 0  (Yazi + FlatArcade + SVG)
check-upstream-pins.sh            current (no bump)
planning/qa/run-all.sh --only pins-static  RESULT: OK (11 PASS)
releases/latest                   CLEAN
ghcr-pull-test.sh --owner neon798 exit 1  (hyprwave unauthorized; cosmic inspect OK)
localhost/hyprwave:latest         9bc0e1e57d6b
localhost/hyprwave-cosmic:latest  189340691cc7
```

Pins still current. Docs already match private GHCR + CI run `31662742064`.
Dependabot still skipped (majors + same-day push path). No invented follow-up.

## 2026-08-13 — A-W2-002

**status:** DONE  
**branch:** `lane/a-stabilize`

### Work done

- Added `planning/integration/a-stabilize/GHCR-VISIBILITY.md` (copy-paste Public
  clicks for **both** packages; expected 403 until human; post-click probe).
- Pointed `RELEASE.md`, `FIRST-BOOT-CHECKLIST.md`, `INTEGRATION-DAY.md` at it.
  Still **do not** claim anonymous GHCR is public.
- Workflow bumps (exclusive to `build.yml`, SHA-pinned):
  - `docker/metadata-action` 6.1.0 → 6.2.0
  - `docker/login-action` 4.2.0 → 4.5.1
  - `sigstore/cosign-installer` 4.1.0 → 4.1.2 (`cosign-release` still v2.6.3)
- **Skipped majors** (need human/CI soak after last dual-push):
  - `actions/checkout` v6 → v7
  - `redhat-actions/push-to-registry` v2 → v3
- No `versions.env` / pin policy change.

### Validation

```
planning/qa/run-all.sh --only pins-static  RESULT: OK (11 PASS)
releases/latest in build.sh / versions.env  CLEAN
build.yml + build-disk.yml YAML parse OK
```

### Commits (this task)

1. merge `origin/main` (A-W2-002 assignment)
2. GHCR-VISIBILITY + RELEASE/first-boot/integration links
3. safe Dependabot SHA bumps in build.yml
4. taskmaster DONE + WORK_LOG/COMPLETED

## 2026-08-13 — A-W3-001

**status:** DONE  
**branch:** `lane/a-stabilize`

### Work done

- Stamped `FIRST-BOOT-CHECKLIST.md` Wave 3 image proofs:
  local `localhost/hyprwave:latest` (9bc0e1e57d6b / sha256:a935dbeb…) and
  `localhost/hyprwave-cosmic:latest` (189340691cc7 / sha256:a9ca6920…);
  CI run `31662742064` dual-image **PASS**; VM smoke **OPEN**.
- GHCR remains documented as 403/`unauthorized` (not public).
- **Pins still current** (no `versions.env` bump).

### Pin verify

```
verify-pins.sh --head --light     exit 0  (4× HTTP 200)
planning/qa/run-all.sh --only pins-static  RESULT: OK (11 PASS)
releases/latest                   CLEAN
```

### Commits

1. merge `origin/main` (A-W3-001 assignment)
2. FIRST-BOOT-CHECKLIST Wave 3 stamp + run log
3. taskmaster DONE

## 2026-08-13 — A-W3-001 reconfirm (main still OPEN)

**status:** DONE (no new product work)

Director copy on `origin/main` still listed A-W3-001 OPEN. Stamp already on
lane (`c845521`). Re-ran gates:

```
verify-pins.sh --head --light     exit 0
planning/qa/run-all.sh --only pins-static  RESULT: OK (11 PASS)
```

Pins still current. GHCR still documented 403. VM smoke still OPEN.
No invented follow-up.

## 2026-08-13 — A-W4-001

**status:** DONE  
**branch:** `lane/a-stabilize`

### Work done

- MERGE-READY.md Wave 4 exclusive inventory vs `origin/main` /
  `post-integration-20260807` (commits + files; `build.sh` pin block unchanged).
- INTEGRATION-DAY points at that section.
- pin_guards still pass. GHCR still documented private. No Dependabot majors.

### Pin verify

```
verify-pins.sh --head --light                 exit 0
planning/qa/run-all.sh --only pins-static     RESULT: OK (11 PASS)
releases/latest                               CLEAN
```

**Pins still current.**

### Commits

1. merge `origin/main` (A-W4-001 assignment)
2. MERGE-READY / INTEGRATION-DAY inventory
3. taskmaster DONE

## 2026-08-13 — A-W5-001

**status:** DONE  
**branch:** `lane/a-stabilize`

### Merge SHA

`42450b1` — `merge: lane/a-stabilize Wave 2–4 (pins, GHCR card, CI action bumps)`
(`origin/main` = `42450b12bb0f7652503a6a21668f881008d3fa66`)

Lane catch-up: `17cf678` Merge origin/main into lane/a-stabilize.

### Confirmations

- `pins-static` PASS (11) on merged tree
- `build.yml` on main HEAD has A-W2-002 SHAs:
  metadata-action `dc802804` v6.2.0; login-action `abd2ef45` v4.5.1;
  cosign-installer `6f9f1778` v4.1.2; checkout still v6; push-to-registry still v2
- GHCR still documented private (`GHCR-VISIBILITY.md` / `RELEASE.md` 403)
- Exclusive paths vs `origin/main`: empty (already landed)
- No new features

### Commits

1. merge `origin/main` (`42450b1`)
2. taskmaster DONE

## 2026-08-13 — A-W5-001 reconfirm (main still OPEN)

**status:** DONE (no new product work)

Re-merged `origin/main` (director STATUS only). Re-ran `pins-static` PASS.
Action SHAs still on HEAD. Merge SHA still `42450b1`. GHCR still private.
No invented follow-up.

## 2026-08-13 — A-W5-001 heartbeat (main still OPEN)

**status:** DONE — no product work. Merged E-hyprland from main onto lane.
`pins-static` PASS; action SHAs unchanged. Still `42450b1`.

## 2026-08-13 — A-W5-001 reconfirm (B/C W5 issued; A still OPEN)

**status:** DONE (no new product work)

`origin/main` still lists **A-W5-001 OPEN** (director STATUS stale vs B/C
CURRENT_TASK files, which are now B-W5-001 / C-W5-001). Re-merged: already
up to date. Re-ran:

```
planning/qa/run-all.sh --only pins-static  RESULT: OK (11 PASS)
```

Action SHAs unchanged (`dc802804` / `abd2ef45` / `6f9f1778`; checkout v6;
push-to-registry v2). GHCR still documented 403. Merge SHA still `42450b1`.
No invented follow-up.

## 2026-08-13 — A-W5-001 reconfirm (D/F/G Wave 4 on main)

**status:** DONE (no new product work)

Director copy on `origin/main` still lists **A-W5-001 OPEN**. Merged
`origin/main` (`07be046` g-qa W2–4 + f-cosmic + d-duress) into the lane:

- **lane merge SHA:** `754ed9e`
- **A product merge on main:** still `42450b1`

Re-ran:

```
planning/qa/run-all.sh --only pins-static  RESULT: OK (11 PASS)
```

`build.yml` A-W2-002 SHAs still on HEAD:
metadata-action `dc802804` v6.2.0; login-action `abd2ef45` v4.5.1;
cosign-installer `6f9f1778` v4.1.2; checkout v6; push-to-registry v2.
GHCR still documented private (`GHCR-VISIBILITY.md` 403). No pin bump.
No invented follow-up.

## 2026-08-13 — A-W5-001 heartbeat (main still OPEN)

**status:** DONE (no new product work)

`origin/main` still `07be046`; already merged (`754ed9e`). Re-ran
`pins-static` PASS (11). Action SHAs unchanged. GHCR still private.
No invented follow-up.

## 2026-08-13 — A-W5-001 heartbeat (main still OPEN)

**status:** DONE (no new product work)

Still `07be046` / lane merge `754ed9e`. `pins-static` PASS (11).
A-W2-002 SHAs unchanged. GHCR still 403. No invented follow-up.

## 2026-08-13 — A-W5-001 heartbeat (main still OPEN)

**status:** DONE (no new product work)

Unchanged tip `07be046` / `754ed9e`. `pins-static` PASS (11).
SHAs `dc802804`/`abd2ef45`/`6f9f1778`. GHCR still private. No invented work.

## 2026-08-13 — A-W5-001 heartbeat (main still OPEN)

**status:** DONE (no new product work)

Still `07be046` / `754ed9e`. `pins-static` PASS (11). Action SHAs
unchanged. GHCR still private. No invented follow-up.
