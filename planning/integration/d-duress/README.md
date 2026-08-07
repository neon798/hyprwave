# Integration: Model D — Duress (lane/d-duress)

## Wave 1 + Wave 2 + security pack delivered

| Artifact | Purpose |
|---|---|
| `build_files/build-duress.sh` | Pin + compile pam-duress → `$DESTROOT` (prints pin/date; `PAM_DURESS_COMMIT` override) |
| `build_files/duress/` | Templates (mild + local-clear + aggressive), setup tool, PAM **snippets**, THREAT-MODEL, ENABLE |
| `build.sh.snippet` | Deploy packaging; **no PAM enable** (`DURESS=assets` intent) |
| `Containerfile.snippet` | Optional `duressbuilder` stage |
| `ENABLE.md` | Admin enable / recovery / bootc PAM drift / root-shell checklist |
| `DRILL.md` | 30–45 min disposable VM operator procedure |
| `FAQ.md` | Operator Q&A (off by default, signing, greeter/lock, lockout, bootc, LUKS residual) |
| `OPERATOR-RUNBOOK.md` | Ordered enable → VM test → disable/rollback (links DRILL) |
| `SIGNING.md` | Local sign / verify workflow; **never** commit `*.sha256`; disposable lab path |
| `RESIDUALS.md` | What packaging does **not** solve (LUKS, physical access, trust root, bootc drift) |
| `snippet-selftest.sh` | Asserts build/Containerfile snippets stay PAM-inert |
| `validate.sh` | Packaging safety gates + negative fixtures (no `.sha256`, no pam.d writes, threat model) |

## Templates (severity — must match `build_files/duress/README.md`)

| File | Severity | Setup flag |
|---|---|---|
| `templates/00-wipe-sensitive.sh` | **AGGRESSIVE** | `--wipe-template` |
| `templates/10-clear-histories.sh` | **MILD** | `--mild-template` |
| `templates/20-local-only-clear.sh` | **MILD** | `--local-clear-template` |

Operator docs: [FAQ.md](./FAQ.md) · [OPERATOR-RUNBOOK.md](./OPERATOR-RUNBOOK.md) · [SIGNING.md](./SIGNING.md) · [RESIDUALS.md](./RESIDUALS.md) · [DRILL.md](./DRILL.md)

## Setup tool

```bash
hyprwave-duress-setup --dry-run --mild-template
hyprwave-duress-setup --mild-template
hyprwave-duress-setup --local-clear-template
hyprwave-duress-setup --wipe-template
hyprwave-duress-setup --verify
hyprwave-duress-setup --status --json
```

## Validate

```bash
bash planning/integration/d-duress/snippet-selftest.sh
bash planning/integration/d-duress/validate.sh
```

## Integrator merge

1. Land Model A (pins) if concurrent.
2. Apply `Containerfile.snippet` + `build.sh.snippet`.
3. Build both variants; confirm setup tool + module path.
4. **Do not** enable PAM in the same PR unless product + security explicitly want it.
5. Run `validate.sh` in CI if possible.

## Forbidden (kept)

- No production `build.sh` / `Containerfile` edits in this lane (snippets only)
- No default signed scripts / no default PAM lines
- No skel / assistant / product README ownership
