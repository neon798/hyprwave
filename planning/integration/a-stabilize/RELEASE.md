# Hyprwave release / publish notes (Model A)

Operator-facing notes for shipping a reproducible image after pins land.
End-user install prose lives with Model B (`INSTALL.md`); this file is for
maintainers and the morning integrator.

## Image names

| Variant  | Container image (GHCR)                    | Notes |
|----------|-------------------------------------------|--------|
| Hyprland | `ghcr.io/<owner>/hyprwave`                | default `DE=hyprland` |
| COSMIC   | `ghcr.io/<owner>/hyprwave-cosmic`         | `DE=cosmic` matrix leg |

`<owner>` is the GitHub repository owner (e.g. `neon798`). CI sets
`IMAGE_NAME` from the repo name and suffixes `-cosmic` for the COSMIC job.

## Tag scheme (CI)

From `.github/workflows/build.yml` (docker/metadata-action), each successful
push to the default branch produces roughly:

| Tag | Meaning |
|-----|---------|
| `latest` | Moving tip of the default branch build |
| `latest.YYYYMMDD` | Dated tip (same build as `latest` that day) |
| `YYYYMMDD` | Date-only convenience tag |
| `sha-<short>` / PR refs | PR builds only (not pushed/signed) |

**Recommendation for “known good” installs:** prefer a dated tag
(`latest.YYYYMMDD` or `YYYYMMDD`) over bare `latest` when documenting a
release, so `bootc switch` targets do not silently float.

Git tags on the repo (e.g. `v0.1.0`) are optional and not yet wired to the
container tag matrix — if you add them later, map `type=semver` in metadata
without removing the dated tags.

## Publish path (CI)

On **push to default branch** (not PRs):

1. Job **`pin_guards`** — pin hygiene + `bash -n` + versions.env key/sha shape +
   `verify-pins.sh --head` + light checksum (`--checksum --light`).
2. Job **`build_push`** (matrix: hyprland, cosmic) — buildah build (`needs: pin_guards`).
3. Login to GHCR → push tags → Cosign sign with `SIGNING_SECRET`.

PRs build both variants but **do not** push or sign. `pin_guards` still runs on
PRs so floating tags and bad digests fail before review merges.

### Manual re-publish (`workflow_dispatch`)

1. GitHub → Actions → **Build container image** → Run workflow (default branch).
2. Wait for `pin_guards` + both matrix legs green.
3. Confirm new dated tags appear on GHCR packages.
4. Anonymous pull + `cosign verify` (below).

### Digest-pinned install (preferred for “known good”)

After a green publish:

```bash
# Resolve digest for a dated tag
skopeo inspect docker://ghcr.io/<owner>/hyprwave:YYYYMMDD | jq -r .Digest
# or
podman pull ghcr.io/<owner>/hyprwave:YYYYMMDD
podman image inspect ghcr.io/<owner>/hyprwave:YYYYMMDD --format '{{index .RepoDigests 0}}'
```

Document `ghcr.io/<owner>/hyprwave@sha256:…` (digest form) in CHANGELOG when
cutting a release note. Consumers on bootc can switch to the digest ref so a
later retag of `YYYYMMDD` cannot silently change bits.

## GHCR visibility (must-fix for public install)

Wave 1 / Wave 2 probe (2026-08-06; re-check with `ghcr-pull-test.sh`):

| Image | Anonymous pull | Symptom |
|-------|----------------|---------|
| `ghcr.io/neon798/hyprwave:latest` | **FAIL** | unauthorized |
| `ghcr.io/neon798/hyprwave-cosmic:latest` | **FAIL** | 403 Forbidden |

Until packages are **public** (or install docs document authenticated pull):

- `bootc switch` / anonymous `podman pull` from the internet will fail.
- Local `just build` + ISO/qcow2 paths still work for validation.
- Prefer **dated tags** or **digests** over bare `:latest` even after packages
  are public so install targets do not float under operators.

### Maintainer fix checklist (public packages)

1. Open the GitHub org/user → **Packages**.
2. For **each** of `hyprwave` and `hyprwave-cosmic`:
   - Package settings (⋯ or package name → Package settings)
   - **Change visibility** → **Public**
   - Confirm “Inherit access from repository” is acceptable for your threat model
3. Confirm repo secret **`SIGNING_SECRET`** holds the Cosign private key PEM.
4. Confirm root **`cosign.pub`** matches that private key.
5. Actions → **Build container image** → Run workflow on default branch
   (or merge a no-op). Wait for `pin_guards` + both matrix legs + sign.
6. Anonymous pull test (no `podman login`, no `DOCKER_CONFIG` creds):

   ```bash
   bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh --owner <owner>
   # equivalent manual:
   podman pull ghcr.io/<owner>/hyprwave:latest
   podman pull ghcr.io/<owner>/hyprwave-cosmic:latest
   ```

7. Cosign (see `COSIGN.md`):

   ```bash
   cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave:latest
   cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave-cosmic:latest
   ```

### Private-registry contingency (packages stay private)

If packages **must** remain private (org policy):

1. **Document auth for installers** (Model B INSTALL.md owns end-user prose):
   - Create a GitHub PAT with `read:packages`
   - `echo "$PAT" | podman login ghcr.io -u USER --password-stdin`
   - Then `bootc switch` / `podman pull` the intended **dated tag or digest**
2. **CI consumers** (disk workflow) already use `packages: read` + GITHUB_TOKEN
   on Actions runners; public visibility is only required for *anonymous* end users.
3. **Do not** tell users to track floating `:latest` without auth + signature
   verify — private + floating is the worst of both worlds.
4. Mirror option: periodically copy a known-good digest to an internal registry
   your fleet can pull without GitHub credentials; still verify with `cosign.pub`
   at copy time.

### Anonymous pull test (automation)

```bash
# Exit 0 only if both images are readable without credentials
bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh
bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh --tag YYYYMMDD
```

Record the result in `FIRST-BOOT-CHECKLIST.md` run logs (`GHCR anonymous pull`).

## Cosign reminder

Full runbook: **`planning/integration/a-stabilize/COSIGN.md`**.

- Private key: GitHub Actions secret `SIGNING_SECRET` only.
- Public key: repo root `cosign.pub` (commit updates if you rotate).
- Sign step runs only on default-branch non-PR builds (see workflow `if:`).
- Do not commit private keys or unencrypted key material.
- Dual image: always verify **both** `hyprwave` and `hyprwave-cosmic`.

## Companion app pins (reproducibility)

External downloads are **not** floating:

- Source of truth: `build_files/versions.env`
- Build-time verify: `sha256sum -c` in `build_files/build.sh`
- Local/CI URL check: `planning/integration/a-stabilize/scripts/verify-pins.sh`
- Bump procedure: `planning/integration/a-stabilize/BUMP.md` (includes worked example)

Never ship a release that greps positive for `releases/latest` in
`build_files/build.sh` (`pin_guards` enforces this).

### When to bump pins (policy)

| Trigger | Action |
|---------|--------|
| Security advisory in Yazi / Neonwolf / FlatArcade | Bump that component ASAP; rebuild + publish |
| Broken download / 404 on pinned tag | Bump to a live tag or restore last known-good pin |
| Intentional feature pull for a release | Bump during release freeze window; run `--checksum` |
| Daily upstream noise | **Do not** chase; pins are deliberate |

After any bump: `verify-pins.sh` (then `--checksum --light` or full `--checksum`),
commit `versions.env` only, let `pin_guards` pass, dual-variant image build.

### Rollback

**Bad companion pin (build still succeeding but app broken):**

1. Revert the `versions.env` commit (see BUMP.md worked example §6).
2. Rebuild both images and re-push so `latest` is healthy.
3. Prefer telling installers to use a **dated** tag (`YYYYMMDD`) until `latest` is fixed.

**Bad full OS image already on GHCR:**

1. Identify last good tag: `podman pull ghcr.io/<owner>/hyprwave:YYYYMMDD` (or digest).
2. Consumers on bootc: switch/rebase back to that tag, e.g.  
   `bootc switch ghcr.io/<owner>/hyprwave:YYYYMMDD` then reboot (exact flags per INSTALL).
3. Do **not** delete GHCR tags casually — mark / document bad digests in CHANGELOG.
4. Cosign: verify the rollback tag still matches `cosign.pub` before recommending it.

**CI false failure on pin_guards network flake:**

1. Re-run the failed job (HEAD to GitHub can flake).
2. If URL permanently 404, treat as pin breakage and roll pin forward/back — do not disable `pin_guards`.

## Suggested release checklist (morning)

- [ ] `lane/a-stabilize` merged (pins + CI guards)
- [ ] Dual build green: `just build` + `just build-cosmic` (or CI matrix)
- [ ] `CI-MATRIX.md` still matches workflow matrix (hyprland + cosmic)
- [ ] GHCR packages public; `ghcr-pull-test.sh` exit 0 (or private contingency documented)
- [ ] Cosign verify with `cosign.pub` succeeds for **both** images (`COSIGN.md`)
- [ ] FIRST-BOOT-CHECKLIST filled for at least one DE (pass/fail log)
- [ ] Dated GHCR tag / digest recorded in CHANGELOG (Model B) when docs merge
- [ ] Assistant/Duress hooks applied only via integrator snippets (not this lane)

## Related (this lane)

| Doc / script | Role |
|--------------|------|
| `MERGE-READY.md` | Pre-merge green gate for `lane/a-stabilize` |
| `INTEGRATION-DAY.md` | One-page ordered merge/verify run sheet |
| `CI-MATRIX.md` | Dual-image CI audit + gaps |
| `COSIGN.md` | Verify / rotate / failure modes |
| `scripts/verify-pins.sh` | Companion pin HEAD/checksum |
| `scripts/check-upstream-pins.sh` | Advisory upstream tag compare (not CI) |
| `scripts/ghcr-pull-test.sh` | Anonymous dual-image GHCR probe |
| `BUMP.md` | Pin bump worked example |
| `FIRST-BOOT-CHECKLIST.md` | Post-boot validation log |

## Out of scope for Model A

- NVIDIA proprietary driver certification (hardware-dependent)
- Full marketing README (Model B)
- Feature enablement for Assistant / Duress (C/D + human review)
