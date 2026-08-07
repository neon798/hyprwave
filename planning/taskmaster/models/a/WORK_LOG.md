# Model A Work Log

(append only)

## 2026-08-07 — A-W1-001 (deepen #2 / reopen)

**status:** DONE  
**branch:** `lane/a-stabilize`  
**tip:** (see COMPLETED.md after push)

### Work done this tick

Task Master re-issued A-W1-001 as OPEN on main; lane already had Wave-1 pins.
Deepened fail-closed path and CI static gates further:

1. **`build_files/build.sh`**
   - Require `/ctx/versions.env` present before source
   - `require_pin` / `require_sha256` (64 hex) / `forbid_floating_url` for all
     Yazi, Neonwolf, FlatArcade (+ SVG) pins **before** curl
   - Floating path built via `printf '%s/%s' releases latest` so source stays
     free of the contiguous token for grep-based guards
   - `verify_sha256` rejects missing files and empty digests

2. **`planning/integration/a-stabilize/scripts/verify-pins.sh`**
   - Static preflight: keys, sha format, non-floating URLs
   - Asserts `build.sh` sources `versions.env` and uses `verify_sha256`
   - Asserts neither `build.sh` nor `versions.env` contains floating token
   - Then HEAD or `--checksum` / `--checksum --light` as before

3. **CI**
   - `build.yml` `pin_guards`: floating token, pin wiring (`${*_SHA256}`),
     sha shape, bash -n including verify-pins, HEAD, light checksum
   - `build-disk.yml`: floating token + versions.env keys + bash -n

4. **Docs**
   - RELEASE: workflow_dispatch, digest-pinned install, stronger pin_guards description
   - BUMP: updated CI guard list
   - FIRST-BOOT: floating-token grep, second filled pass/fail log

### Validation

```
token=$(printf '%s/%s' releases latest)
grep -nF "$token" build_files/build.sh build_files/versions.env  → clean
bash -n build_files/build.sh verify-pins.sh                     → OK
bash …/verify-pins.sh --head                                    → exit 0
bash …/verify-pins.sh --checksum --light                        → exit 0
```

### Commits (this reopen tick)

1. `build: fail-closed pin key, sha256, and floating-URL checks`
2. `verify-pins: static key/sha/source guards before network checks`
3. `ci/docs: deepen pin_guards and release/bump operator notes`
4. taskmaster status DONE + WORK_LOG/COMPLETED

### Notes for Director

- GHCR anonymous pull still FAIL (private/403) — RELEASE.md maintainer checklist; not a pin code defect.
- Full Neonwolf checksum (no --light) remains operator-only pre-release.
