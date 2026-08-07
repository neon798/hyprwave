# CI matrix audit (Model A — A-W1-002)

Operator reference for how dual Hyprland + COSMIC images are built, gated,
and published. Source of truth remains the workflow YAML; this file is the
audit snapshot and gap list for integrators.

## Workflows

| File | Purpose | Triggers |
|------|---------|----------|
| `.github/workflows/build.yml` | Container images → GHCR + Cosign | PR → `main`, push → `main` (README-only ignored), daily cron `05 10 * * *`, `workflow_dispatch` |
| `.github/workflows/build-disk.yml` | qcow2 / Anaconda ISO via bootc-image-builder | `workflow_dispatch` (platform + optional S3), PR → `main` **only when** `disk_config/*` or this workflow changes |

## Image names (must stay in sync)

| DE (`build-arg DE=`) | GHCR package | How name is formed |
|----------------------|--------------|--------------------|
| `hyprland` (default) | `ghcr.io/<owner>/<repo>` e.g. `…/hyprwave` | `IMAGE_NAME = github.event.repository.name` (lowercased) |
| `cosmic` | `ghcr.io/<owner>/<repo>-cosmic` e.g. `…/hyprwave-cosmic` | same base + `-${{ matrix.de }}` / `-cosmic` suffix |

Both workflows use the same suffix rule:

- **build.yml** (`build_push` job): if `matrix.de != hyprland` → append `-${{ matrix.de }}`
- **build-disk.yml**: if `matrix.de == cosmic` → append `-cosmic`

## build.yml job graph

```
pin_guards  ──needs──►  build_push [hyprland | cosmic]
   │                         │
   │ PR + push + schedule    │ build always
   │ + dispatch              │ push + cosign only if:
   │                         │   event != pull_request
   │                         │   AND ref == default branch
```

### `pin_guards` (single job, no DE matrix)

Runs on **every** workflow trigger, including PRs. Failures block `build_push`.

Checks (A-W1-001 + A-W1-002):

- No floating GitHub release token in `build_files/build.sh` / `versions.env`
- `build.sh` sources `versions.env` and references each `${*_SHA256}`
- Dual DE matrix still present in this workflow file (hyprland + cosmic)
- `bash -n` on `build_files/**/*.sh` + `verify-pins.sh`
- Required keys + 64-char hex digests in `versions.env`
- `verify-pins.sh --head`
- `verify-pins.sh --checksum --light` (skips large Neonwolf AppImage)

### `build_push` matrix

```yaml
strategy:
  fail-fast: false
  matrix:
    de: [hyprland, cosmic]
```

- Build-arg: `DE=${{ matrix.de }}`
- Tags (metadata-action): `latest`, `latest.YYYYMMDD`, `YYYYMMDD`, plus PR `sha-` / ref tags
- Cosign: `cosign sign --key env://COSIGN_PRIVATE_KEY` for each tag (private key from `SIGNING_SECRET`)

## build-disk.yml matrix

| de | disk-type | config | GHCR image consumed |
|----|-----------|--------|---------------------|
| hyprland | qcow2 | `disk_config/disk.toml` | `…/hyprwave:latest` |
| hyprland | anaconda-iso | `disk_config/iso.toml` | `…/hyprwave:latest` |
| cosmic | anaconda-iso | `disk_config/iso-cosmic.toml` | `…/hyprwave-cosmic:latest` |

Pin hygiene on this workflow (inline, not a separate job):

- Forbid floating-release token in `build.sh` / `versions.env`
- Required `versions.env` keys + `bash -n`
- `verify-pins.sh --head` when the script exists (network; fail closed)

Disk builds **pull** prebuilt GHCR images; they do not re-run the container
build. Pins here only catch tree drift before BIB runs.

## PR behaviour (release safety)

| Event | pin_guards | dual container build | push/sign | disk images |
|-------|------------|----------------------|-----------|-------------|
| PR → main | **yes** | **yes** (both DE) | no | only if disk paths changed; pin steps still run |
| push → main | **yes** | **yes** | **yes** | no (dispatch only unless paths match) |
| schedule | **yes** | **yes** | **yes** | no |
| workflow_dispatch (build) | **yes** | **yes** | **yes** (default branch) | n/a |
| workflow_dispatch (disk) | inline pin steps | n/a | n/a | **yes** |

## Gaps / follow-ups (documented, not all fixed this task)

| Gap | Severity | Notes / contingency |
|-----|----------|---------------------|
| GHCR packages private/403 for anonymous pull | **High** for public install | 2026-08-07: `hyprwave:latest` unauthorized; `hyprwave-cosmic:latest` sometimes readable — treat **both** as must-public; `scripts/ghcr-pull-test.sh` fails closed if either fails |
| No COSMIC **qcow2** in disk matrix | Low | Only hyprland qcow2; cosmic is ISO-only today |
| Disk workflow does not `workflow_call` / wait on `build.yml` | Medium | Disk assumes GHCR `:latest` already published; operators must run container build first |
| `BIB_IMAGE` uses `bootc-image-builder:latest` | Low | Floating builder; pin if reproducibility of *disk* tooling becomes critical |
| ArtifactHub metadata still generic (`IMAGE_DESC`) | Cosmetic | Optional polish; does not affect bootability |
| Repo git tags (`vX.Y.Z`) not mapped to container tags | Low | Dated tags suffice; optional `type=semver` later |
| Cosign verifies tags, not necessarily every digest in one command | Low | See `COSIGN.md` for verify-by-tag and by-digest |
| `concurrency` group references unused `inputs.brand_name` / `stream_name` | Cosmetic | Harmless leftovers from template |

## Operator quick checks

```bash
# Local pin gate (same spirit as pin_guards)
bash planning/integration/a-stabilize/scripts/verify-pins.sh --head

# Confirm dual matrix still declared
grep -n 'de: \[hyprland, cosmic\]' .github/workflows/build.yml

# Anonymous GHCR probe (both packages)
bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh
```

## Related docs

- `MERGE-READY.md` — minimum green gate before merging `lane/a-stabilize`
- `RELEASE.md` — publish path, GHCR visibility, rollback
- `COSIGN.md` — verify / rotate / failure modes
- `BUMP.md` — companion app pins
- `FIRST-BOOT-CHECKLIST.md` — post-install validation log
