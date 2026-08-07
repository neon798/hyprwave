# Hyprwave packaging QA harness

Host-side checks for **packaging invariants** across lanes A–F.  
Model G owns this tree (`planning/qa/**`). It does **not** merge product lanes.

## Quick start

From the repo root (any branch that contains this tree):

```bash
bash planning/qa/run-all.sh
```

Exit `0` if no check **FAIL**s. **WARN** / soft-skip for missing lane artifacts is allowed and printed (not a silent pass).

### Options

```bash
bash planning/qa/run-all.sh --list
bash planning/qa/run-all.sh --only pins-static,themes
NO_COLOR=1 bash planning/qa/run-all.sh
```

## Checks

| ID | Script | What it enforces |
|---|---|---|
| `pins-static` | `check-pins-static.sh` | No `/releases/latest` in `build_files/build.sh`; if `versions.env` exists, required pin keys + sha256 shape |
| `themes` | `check-themes.sh` | Each theme under `build_files/usr/share/hyprwave/themes/*` has looknfeel, waybar/walker styles, ghostty config, wallpapers (or documented exception) |
| `no-wofi-swaybg` | `check-no-wofi-swaybg.sh` | Skel / theme trees do not reintroduce Wofi or swaybg |
| `duress-safety` | `check-duress-safety.sh` | If duress packaging present: no `*.sha256`; run `planning/integration/d-duress/validate.sh` when available |
| `assistant` | `check-assistant.sh` | If `apps/hyprwave-assistant` present: `go test ./...` |
| `lane-artifacts` | `check-lane-artifacts.sh` | Optional multi-ref: expected paths on `origin/lane/*` (or `ORIGIN_LANE_*`); WARN if ref missing; FAIL only if ref present but path missing |

### Soft-skip policy

When a lane is **not** merged into the tree under test:

- The check prints **WARN** with the missing path.
- That is **not** counted as PASS for that artifact.
- `run-all.sh` still exits `0` if nothing hard-failed (so main can stay green before integration).
- After merging A/C/D, re-run; WARNs should become PASS or surface real FAILs.

`lane-artifacts` is the multi-ref cousin: missing **remote-tracking refs** are WARN (fetch not required for a green host tree). Set `LANE_ARTIFACTS_OFF=1` in shallow CI if you only want tree-local checks.

### Exit semantics (`run-all.sh`)

| Code | Meaning |
|---|---|
| `0` | No check **FAIL**ed. WARN and SKIP are allowed. |
| `1` | At least one check exited non-zero / recorded FAIL. |
| `2` | Harness misuse (unknown `--only` id, bad CLI). |

Individual check scripts exit `0` when `FAIL_COUNT==0` (via `qa_exit_code`), else `1`.

## Layout

```
planning/qa/
  README.md                 # this file
  run-all.sh                # orchestrator + summary table
  check-pins-static.sh
  check-themes.sh
  check-no-wofi-swaybg.sh
  check-duress-safety.sh
  check-assistant.sh
  check-lane-artifacts.sh   # multi-ref residual checks
  probe-merge-conflicts.sh  # read-only merge-tree probe (not in run-all)
  ci-snippet.yml            # copy-paste GH job (not a live workflow)
  theme-exceptions.list     # optional theme:component exceptions
  lib/common.sh             # PASS/FAIL/WARN helpers
```

## Relationship to other lanes

| Lane | Artifact the harness consumes |
|---|---|
| A stabilize | `build_files/versions.env`, no `releases/latest`, optional `verify-pins.sh` |
| B docs | Not automated here (prose); smoke matrix references INSTALL/CHANGELOG |
| C assistant | `apps/hyprwave-assistant` + `go test` |
| D duress | `build_files/duress/**`, `validate.sh` |
| E hyprland | Theme/skel assumptions; `SESSION-SMOKE.md` linked from smoke matrix |
| F cosmic | `SESSION-SMOKE.md` linked from smoke matrix |

Integration **order and conflict hotspots** live in:

- `planning/integration/g-qa/MERGE-PLAYBOOK.md`
- `planning/integration/g-qa/SMOKE-MATRIX.md`

## Local prerequisites

| Check | Needs |
|---|---|
| pins / themes / wofi | bash, grep, find (always) |
| duress validate | bash; optional files from D |
| assistant | Go toolchain (`go` on `PATH`) matching `go.mod` |
| lane-artifacts | `git` + fetched `origin/lane/*` (optional; soft-WARN without) |

## Adding a check

1. Add `planning/qa/check-<name>.sh` that sources `lib/common.sh`, prints results via `qa_pass` / `qa_fail` / `qa_warn`, ends with `qa_exit_code`.
2. Register it in `run-all.sh` (`CHECK_ORDER` + `CHECK_SCRIPTS`).
3. Document it in this README table.
4. Keep scripts **read-only** w.r.t. product trees (no writing outside `planning/qa` / temp).

## CI suggestion (integrator / Model A)

Prefer the ready-to-copy job file:

- **`planning/qa/ci-snippet.yml`** — static / full / advisory lane-ref jobs, no secrets.

Minimal inline static job (no network, no Go):

```yaml
- name: Packaging QA
  run: bash planning/qa/run-all.sh --only pins-static,themes,no-wofi-swaybg
  env:
    NO_COLOR: "1"
    LANE_ARTIFACTS_OFF: "1"
```

Full harness (including `go test`, duress validate, optional lane refs) after C/D merge:

```yaml
- name: Packaging QA (full)
  run: bash planning/qa/run-all.sh
  env:
    NO_COLOR: "1"
```

Endpoint residual tracker (human-maintained from harness + `git ls-tree`):

- `planning/integration/g-qa/ENDPOINT-RESIDUALS.md`

Integration day (human master procedure):

- `planning/integration/g-qa/INTEGRATION-DAY.md`

Pre-merge conflict dry-run (integrator):

- `planning/integration/g-qa/PRE-MERGE-DRY-RUN.md`
- `bash planning/qa/probe-merge-conflicts.sh --product-only`

### Probe script (not in `run-all.sh`)

`probe-merge-conflicts.sh` uses read-only `git merge-tree` against `origin/main` (or `--base`).  
It is **integration-time advisory**, not a packaging invariant of the checked-out tree, so it is **not** registered in `run-all.sh` (avoids FAIL noise from expected `planning/taskmaster/**` add/add conflicts). Use `--product-only` for product go/no-go; `--fail-on-conflict` only when you want a hard gate.
