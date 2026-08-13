# Merge-ready gate — `lane/a-stabilize` (Model A)

Minimum green checklist before the morning integrator merges **Model A first**.
Companion-app pins, dual-image CI gates, and release docs land here so later
lanes (B–G) do not reintroduce floating downloads or single-variant CI.

## Why A merges first

| Reason | Detail |
|--------|--------|
| Shared build truth | `build_files/versions.env` + `build.sh` pin/checksum path is used by every DE image |
| CI fail-closed | `pin_guards` blocks PRs/merges that reintroduce floating GitHub release redirects |
| Dual image | Matrix must keep `hyprland` + `cosmic` before other lanes rely on either package |
| Docs for operators | `RELEASE.md` / `COSIGN.md` / `CI-MATRIX.md` / this file tell the integrator what “green” means |

Later lanes own product polish (skel, assistant, duress, handbook). They must
**not** edit pin URLs or disable `pin_guards`. Integrator applies C/D hooks via
reviewed snippets after A is on `main`.

## Conflict risks

| Path | Risk if another lane touches it | Resolution |
|------|---------------------------------|------------|
| `build_files/build.sh` | Non-pin edits (Assistant/Duress hooks) collide with pin block | A owns pin/checksum only; feature hooks via integrator after merge |
| `build_files/versions.env` | Bump races | Single pin owner; use `BUMP.md` |
| `.github/workflows/build.yml` | Matrix or `pin_guards` weakened | Reject PRs that drop `de: [hyprland, cosmic]` or floating-token checks |
| `.github/workflows/build-disk.yml` | Disk matrix / pin steps removed | Keep floating-token + keys + `verify-pins --head` |
| `planning/integration/a-stabilize/**` | Docs only — low code risk | Prefer additive edits |

**Git tip:** merge A with a linear history if possible; if conflict in `build.sh`,
keep A’s pin block (source `versions.env` + `verify_sha256` + fail-closed
helpers) and re-apply foreign feature hunks below it.

## Pin freeze status (A-W1-003)

Recorded on `lane/a-stabilize` (UTC **2026-08-07**):

| Check | Result |
|-------|--------|
| Floating-release token in `build.sh` / `versions.env` | **clean** |
| `bash planning/integration/a-stabilize/scripts/verify-pins.sh --head` | **exit 0** |
| `…/verify-pins.sh --checksum --light` | **exit 0** (Yazi + FlatArcade + SVG) |
| `build.yml` forbids floating token + runs HEAD + light checksum | **yes** (`pin_guards`, all PR/push/schedule/dispatch) |
| `build-disk.yml` forbids floating token + keys + HEAD | **yes** (inline steps; no full light checksum — intentional, see below) |

Pins (source of truth `build_files/versions.env`):

| Component | Version pin |
|-----------|-------------|
| Yazi | `v26.5.6` |
| Neonwolf | `v152.0.1-3` |
| FlatArcade | `v0.1.0` |

Bump only via `BUMP.md` after freeze if security forces it; re-run verify-pins.

### Workflow agreement (container vs disk)

| Gate | build.yml `pin_guards` | build-disk.yml |
|------|------------------------|----------------|
| Floating-release token grep | yes | yes |
| `build.sh` sources / `verify_sha256` wiring | yes | no (disk does not rebuild companion apps from this tree’s curl block) |
| Dual DE matrix declaration | yes (hyprland+cosmic + iso-cosmic) | matrix includes cosmic ISO; dual-DE step added for iso-cosmic presence |
| `versions.env` keys + sha shape | yes | keys yes; sha shape not re-checked (HEAD covers reachability) |
| `bash -n` scripts | yes | `build.sh` + verify-pins |
| `verify-pins --head` | yes | yes |
| `verify-pins --checksum --light` | yes | **no** — intentional: disk job pulls GHCR image; full pin digest already gated on container CI |

**No intentional gap** on floating-token enforcement: both workflows fail closed.

## Minimum green gate (merge A)

### Local (integrator machine)

```bash
git fetch origin
git checkout lane/a-stabilize   # or merge commit under test
git rev-parse --short HEAD

# 1) Pins
token=$(printf '%s/%s' releases latest)
grep -nF "$token" build_files/build.sh build_files/versions.env && exit 1 || echo OK
bash planning/integration/a-stabilize/scripts/verify-pins.sh --head
bash planning/integration/a-stabilize/scripts/verify-pins.sh --checksum --light

# 2) Shell syntax (optional if CI will run)
bash -n build_files/build.sh
bash -n planning/integration/a-stabilize/scripts/verify-pins.sh

# 3) Dual matrix still declared
grep -nE 'de:[[:space:]]*\[hyprland,[[:space:]]*cosmic\]' .github/workflows/build.yml
grep -n 'iso-cosmic.toml' .github/workflows/build-disk.yml

# 4) Full image build when hardware/time allows (not strictly required to merge A
#    if CI matrix is trusted, but required before cutting a release image)
just build              # DE=hyprland
just build-cosmic       # DE=cosmic
```

### GitHub Actions expectations after merge to `main`

1. Workflow **Build container image** runs:
   - Job **`pin_guards`** green
   - Job **`build_push`** green for **both** matrix legs (`hyprland`, `cosmic`)
   - On default branch only: push + Cosign sign both packages
2. Disk workflow is **not** required for A-merge; run via `workflow_dispatch` when
   publishing ISOs/qcow2 **after** GHCR has the new digests.

### Post-merge verify (quick)

```bash
bash planning/integration/a-stabilize/scripts/verify-pins.sh --head
# After GHCR public (or with auth):
bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh
cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave:latest
cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave-cosmic:latest
```

See `COSIGN.md` and `RELEASE.md` for failure modes and private-registry contingency.

## Out of scope for “A green”

- GHCR package visibility (maintainer Settings → Packages → Public) — **does not
  block merging A**; blocks public `bootc switch` only
- NVIDIA / Secure Boot certification
- Handbook / INSTALL (Model B)
- Assistant / Duress enablement (C/D + human review)
- Full VM first-boot (use `FIRST-BOOT-CHECKLIST.md` when a machine is free)

## Wave 4 exclusive inventory (A-W4-001)

Recorded **2026-08-13** on `lane/a-stabilize` (`85cbe67` + this commit).
Baseline: tag `post-integration-20260807` / `origin/main` merge-base
`fe1bcbab`. **Do not** merge this lane onto `main` from this doc — inventory only.

### pin_guards still pass

```
verify-pins.sh --head --light                 exit 0
planning/qa/run-all.sh --only pins-static     RESULT: OK (11 PASS)
floating-release token in build.sh / versions.env  CLEAN
build.yml pin_guards: HEAD + --checksum --light + matrix de: [hyprland, cosmic]
checkout remains v6; push-to-registry remains v2 (majors not landed)
```

Pins unchanged: Yazi `v26.5.6`, Neonwolf `v152.0.1-3`, FlatArcade `v0.1.0`.

GHCR: still **private** (anonymous `hyprwave` 403). See `GHCR-VISIBILITY.md`.
Does **not** block merging A.

### Exclusive-path commits since `post-integration-20260807`

(Only `versions.env`, `build.sh` pin logic, `.github/workflows/*`,
`planning/integration/a-stabilize/**` — taskmaster `models/a` omitted.)

| Commit | Summary |
|--------|---------|
| `f758ebb` | docs: Wave 1 CI closeout (pins + private GHCR) |
| `41aaab6` | docs: `GHCR-VISIBILITY.md` copy-paste card |
| `00bc0da` | ci: login-action 4.5.1, metadata-action 6.2.0, cosign-installer 4.1.2 |
| `c845521` | docs: FIRST-BOOT local+CI proofs (VM smoke OPEN) |

### Exclusive files vs `origin/main`

| Path | Why it differs |
|------|----------------|
| `.github/workflows/build.yml` | SHA bumps above; `pin_guards` intact |
| `build_files/versions.env` | operator verify comment only (no tag bump) |
| `planning/integration/a-stabilize/COSIGN.md` | unsigned/private GHCR note |
| `planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md` | Wave 3 proofs + 403 |
| `planning/integration/a-stabilize/GHCR-VISIBILITY.md` | **new** operator card |
| `planning/integration/a-stabilize/INTEGRATION-DAY.md` | visibility link |
| `planning/integration/a-stabilize/RELEASE.md` | CI closeout + visibility pointer |
| `planning/integration/a-stabilize/MERGE-READY.md` | this inventory |

`build_files/build.sh` pin block is **identical** to `origin/main`.

### Not in this merge (skipped)

- `actions/checkout` v7 and `push-to-registry` v3 (majors)
- VM first-boot (still OPEN)
- Flipping GHCR Public (human)

## Related

| Doc | Role |
|-----|------|
| **`INTEGRATION-DAY.md`** | **One-page ordered run sheet for merge day** |
| `BUMP.md` | How to change pins after freeze |
| `CI-MATRIX.md` | Dual-image CI audit |
| `COSIGN.md` | Signature verify |
| `RELEASE.md` | Publish + GHCR |
| `FIRST-BOOT-CHECKLIST.md` | Post-install log |
| `scripts/verify-pins.sh` | Pin HEAD/checksum |
| `scripts/check-upstream-pins.sh` | Advisory “is there a newer tag?” (never CI-fail) |
| `scripts/ghcr-pull-test.sh` | Anonymous dual pull |
