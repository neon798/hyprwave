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
