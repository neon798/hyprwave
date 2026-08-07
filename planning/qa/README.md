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

### Soft-skip policy

When a lane is **not** merged into the tree under test:

- The check prints **WARN** with the missing path.
- That is **not** counted as PASS for that artifact.
- `run-all.sh` still exits `0` if nothing hard-failed (so main can stay green before integration).
- After merging A/C/D, re-run; WARNs should become PASS or surface real FAILs.

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

## Adding a check

1. Add `planning/qa/check-<name>.sh` that sources `lib/common.sh`, prints results via `qa_pass` / `qa_fail` / `qa_warn`, ends with `qa_exit_code`.
2. Register it in `run-all.sh` (`CHECK_ORDER` + `CHECK_SCRIPTS`).
3. Document it in this README table.
4. Keep scripts **read-only** w.r.t. product trees (no writing outside `planning/qa` / temp).

## CI suggestion (integrator / Model A)

A static job can run without network:

```yaml
- name: Packaging QA
  run: bash planning/qa/run-all.sh --only pins-static,themes,no-wofi-swaybg
```

Full harness (including `go test` and duress validate) after C/D merge:

```yaml
- name: Packaging QA (full)
  run: bash planning/qa/run-all.sh
```
