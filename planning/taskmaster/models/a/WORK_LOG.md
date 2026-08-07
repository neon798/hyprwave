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
