# Integration-day card — Model A (`lane/a-stabilize`)

One page for the **human integrator**. Merge **A first**, prove pins/CI green,
then pull other lanes. Full rationale lives in linked docs; this is the run sheet.

## Before you start

| Item | Where |
|------|--------|
| Deep merge gate | [`MERGE-READY.md`](./MERGE-READY.md) |
| Dual-image CI audit | [`CI-MATRIX.md`](./CI-MATRIX.md) |
| Cosign verify | [`COSIGN.md`](./COSIGN.md) |
| Pin bump SOP | [`BUMP.md`](./BUMP.md) |
| Publish / GHCR | [`RELEASE.md`](./RELEASE.md) |
| Pin freeze source | `build_files/versions.env` + `build_files/build.sh` (checksum block only) |

**Do not** merge Assistant/Duress/handbook lanes before A if they might touch
`build.sh` pins or workflows without rebasing onto A.

---

## Ordered steps

### 1. Fetch and inspect

```bash
git fetch origin
git log --oneline origin/main..origin/lane/a-stabilize | head -30
# Expect pin_guards, versions.env, planning/integration/a-stabilize/** only
```

### 2. Merge A into main first

```bash
git checkout main
git pull origin main
git merge origin/lane/a-stabilize
# Prefer merge commit or rebase per house style; resolve conflicts carefully
```

**Conflict tips (if any):**

| Path | Keep from A |
|------|-------------|
| `build_files/versions.env` | Entire file (pins + comments) |
| `build_files/build.sh` pin block | Source `/ctx/versions.env`, `verify_sha256`, fail-closed helpers — **above** any later feature hooks |
| `.github/workflows/build.yml` | `pin_guards` job + `matrix.de: [hyprland, cosmic]` + `needs: pin_guards` |
| `.github/workflows/build-disk.yml` | Floating-token pin steps + `verify-pins --head` + cosmic ISO matrix |
| `planning/integration/a-stabilize/**` | Prefer A’s docs; additive merges OK |

If another lane already landed hooks in `build.sh`, **re-apply those hooks below**
A’s pin block — never replace pin/checksum logic with floating URLs.

### 3. Post-merge pin prove (local, required)

Run from the merge result (or `main` after push):

```bash
# Floating GitHub release redirects must not appear as a contiguous token
token=$(printf '%s/%s' releases latest)
if grep -nF "$token" build_files/build.sh build_files/versions.env; then
  echo "FAIL: floating-release token present"; exit 1
fi
echo "OK: no floating-release token"

bash planning/integration/a-stabilize/scripts/verify-pins.sh --head
bash planning/integration/a-stabilize/scripts/verify-pins.sh --checksum --light

# Optional advisory (never fail the merge on this alone)
bash planning/integration/a-stabilize/scripts/check-upstream-pins.sh || true
```

**Expect:** both `verify-pins` commands exit **0**.

### 4. Dual-matrix sanity (local, quick)

```bash
grep -nE 'de:[[:space:]]*\[hyprland,[[:space:]]*cosmic\]' .github/workflows/build.yml
grep -n 'iso-cosmic.toml' .github/workflows/build-disk.yml
```

### 5. Push main and watch CI

```bash
git push origin main
# GitHub → Actions → "Build container image"
# Green required:
#   1) pin_guards
#   2) build_push / hyprland
#   3) build_push / cosmic
# Default branch only: push to GHCR + Cosign sign both packages
```

### 6. Optional post-publish probes

Only after packages exist and (ideally) are public — see [`RELEASE.md`](./RELEASE.md):

```bash
bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh
# exit 0 only if both hyprwave + hyprwave-cosmic are anonymously readable

cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave:latest
cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave-cosmic:latest
# Full runbook: COSIGN.md
```

**GHCR private is not an A-merge blocker.** It blocks public install only; use
private contingency in RELEASE.md until packages are Public.

### 7. Optional full local image (release day, not merge blocker)

```bash
just build          # hyprland
just build-cosmic   # cosmic
```

### 8. Then merge other lanes

Order suggestion: **A →** docs/handbook (B) / product lanes as planned →
Assistant (C) / Duress (D) only with human review of `build.sh` diffs.

---

## Pass/fail tick box (copy into chat)

```
[ ] merge A complete on main
[ ] floating-token grep clean
[ ] verify-pins --head exit 0
[ ] verify-pins --checksum --light exit 0
[ ] pin_guards green on main
[ ] build_push hyprland green
[ ] build_push cosmic green
[ ] (opt) ghcr-pull-test exit 0
[ ] (opt) cosign verify both images
```

## Related scripts

| Script | Role |
|--------|------|
| `scripts/verify-pins.sh` | Static + HEAD / checksum pin gate |
| `scripts/check-upstream-pins.sh` | Advisory “is upstream newer?” (not CI) |
| `scripts/ghcr-pull-test.sh` | Anonymous dual-image GHCR probe |

---

*Last aligned with A-W1-004. If this card and MERGE-READY disagree, prefer
MERGE-READY for policy depth; keep this file as the short ordered run sheet.*
