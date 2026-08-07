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

1. Job **`pin_guards`** — pin hygiene + `bash -n` + URL HEAD checks.
2. Job **`build_push`** (matrix: hyprland, cosmic) — buildah build.
3. Login to GHCR → push tags → Cosign sign with `SIGNING_SECRET`.

PRs build both variants but **do not** push or sign.

## GHCR visibility (must-fix for public install)

Wave 1 / Wave 2 probe (2026-08-06):

| Image | Anonymous pull | Symptom |
|-------|----------------|---------|
| `ghcr.io/neon798/hyprwave:latest` | **FAIL** | unauthorized |
| `ghcr.io/neon798/hyprwave-cosmic:latest` | **FAIL** | 403 Forbidden |

Until packages are **public** (or install docs document `docker login ghcr.io`):

- `bootc switch` / anonymous `podman pull` from the internet will fail.
- Local `just build` + ISO/qcow2 paths still work for validation.

### Maintainer fix checklist

1. GitHub → Packages → each of `hyprwave` and `hyprwave-cosmic` →
   Package settings → Change visibility → **Public**.
2. Confirm `SIGNING_SECRET` repo secret is set (Cosign private key).
3. Confirm `cosign.pub` in-repo matches the private key used in CI.
4. Re-run workflow_dispatch or merge to default branch; wait for green
   `build_push` + sign steps.
5. From a clean machine (no auth):

   ```bash
   podman pull ghcr.io/<owner>/hyprwave:latest
   podman pull ghcr.io/<owner>/hyprwave-cosmic:latest
   ```

6. Optional verify:

   ```bash
   cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave:latest
   ```

## Cosign reminder

- Private key: GitHub Actions secret `SIGNING_SECRET` only.
- Public key: repo root `cosign.pub` (commit updates if you rotate).
- Sign step runs only on default-branch non-PR builds (see workflow `if:`).
- Do not commit private keys or unencrypted key material.

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
- [ ] GHCR packages public; anonymous pull works
- [ ] Cosign verify with `cosign.pub` succeeds
- [ ] FIRST-BOOT-CHECKLIST filled for at least one DE (pass/fail log)
- [ ] Dated GHCR tag recorded in CHANGELOG (Model B) when docs merge
- [ ] Assistant/Duress hooks applied only via integrator snippets (not this lane)

## Out of scope for Model A

- NVIDIA proprietary driver certification (hardware-dependent)
- Full marketing README (Model B)
- Feature enablement for Assistant / Duress (C/D + human review)
