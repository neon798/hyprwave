# Cosign verify runbook (Model A)

How to **verify** signed Hyprwave images as an operator. Private keys never
belong in the repo or in these docs.

## Keys

| Material | Location | Who handles |
|----------|----------|-------------|
| Private key | GitHub Actions secret `SIGNING_SECRET` only | Maintainer / CI |
| Public key | Repo root `cosign.pub` | Committed; used by consumers |

CI signs on **default-branch** non-PR builds only (see `.github/workflows/build.yml`
“Sign container image” step):

```bash
cosign sign -y --key env://COSIGN_PRIVATE_KEY "$IMAGE_FULL:$tag"
```

Both matrix legs are signed independently:

- `ghcr.io/<owner>/hyprwave:<tag>`
- `ghcr.io/<owner>/hyprwave-cosmic:<tag>`

## Prerequisites

```bash
# Install cosign (examples)
# Fedora:   sudo dnf install cosign
# Go:       go install github.com/sigstore/cosign/v2/cmd/cosign@latest
# Binary:   https://github.com/sigstore/cosign/releases  (pin a version)

# Public key from the tree you trust
test -f cosign.pub
```

Anonymous **pull** must work for the package (or you must be logged in). If
pull fails with `unauthorized` / `403`, fix GHCR visibility first (`RELEASE.md`)
or authenticate — verify cannot succeed on an unreadable image.

**2026-08-13:** CI signed both variants on `77755f1` (run `31662742064`).
Anonymous `ghcr.io/neon798/hyprwave:latest` is still **unauthorized**, so
unauthenticated `cosign verify` of that tag will fail until Package visibility
is Public (or you `podman login ghcr.io`). Cosmic inspect can succeed while
hyprland stays private — treat that as **not** a verified public release.

## Verify a tag

```bash
OWNER=neon798   # or your fork owner
TAG=latest      # prefer dated tag: YYYYMMDD or latest.YYYYMMDD

cosign verify --key cosign.pub "ghcr.io/${OWNER}/hyprwave:${TAG}"
cosign verify --key cosign.pub "ghcr.io/${OWNER}/hyprwave-cosmic:${TAG}"
```

Successful verify prints signature payload / claims JSON to stdout and exits 0.

### Prefer digest after first pull

```bash
podman pull "ghcr.io/${OWNER}/hyprwave:${TAG}"
DIGEST=$(podman image inspect "ghcr.io/${OWNER}/hyprwave:${TAG}" --format '{{index .RepoDigests 0}}')
# DIGEST looks like ghcr.io/owner/hyprwave@sha256:…
cosign verify --key cosign.pub "${DIGEST}"
```

Digest verify pins bits; retagging `latest` later cannot silently pass as the
same install target if consumers switch by digest.

## Failure modes

| Symptom | Likely cause | What to do |
|---------|--------------|------------|
| `MANIFEST_UNKNOWN` / pull denied before verify | Private package, wrong name/tag, or never pushed | Public visibility or `podman login ghcr.io`; check Actions green `Push To GHCR` |
| `no matching signatures` | Image never signed, wrong tag, or different key | Confirm default-branch sign step ran; compare `cosign.pub` to key that produced `SIGNING_SECRET` |
| Signature present but verify errors on key | Key rotation without updating `cosign.pub` / re-sign | Restore matching public key or re-sign with current secret and update `cosign.pub` |
| Verify works for hyprwave but not hyprwave-cosmic | Cosmic leg failed push/sign; only one matrix job published | Re-run workflow; inspect matrix job logs |
| Offline / air-gapped verify | Need image + sig in local store | Mirror image and use cosign offline docs; out of band for Wave 1 |

## Key rotation (no private key in git)

1. Generate a new key pair **offline** (`cosign generate-key-pair`); store private
   material in a password manager / HSM — never commit it.
2. Update GitHub secret `SIGNING_SECRET` to the new private key PEM.
3. Replace repo `cosign.pub` with the new public key; commit on default branch.
4. Re-run **Build container image** (`workflow_dispatch` or merge) so both
   `hyprwave` and `hyprwave-cosmic` tags are signed with the new key.
5. Tell operators to pull the updated `cosign.pub` before verifying new digests.
6. Old images signed with the previous key will **fail** verify against the new
   `cosign.pub` — keep a dated copy of the old public key if you must audit
   historical digests.

## What Cosign does *not* cover

- Companion app pins (Yazi / Neonwolf / FlatArcade) — those are sha256 in
  `versions.env` / `verify-pins.sh`, not image signatures.
- Content of unsigned local `just build` images — only GHCR-published signed
  tags from CI are in scope.
- End-user INSTALL prose (Model B); this runbook is for maintainers/integrators.

## Quick smoke after publish

```bash
bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh
cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave:latest
cosign verify --key cosign.pub ghcr.io/<owner>/hyprwave-cosmic:latest
```
