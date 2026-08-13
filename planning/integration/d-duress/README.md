# Integration: Model D — Duress (lane/d-duress)

## Wave 1–4 packaging + security pack (assets only; PAM never default-on)

| Artifact | Purpose |
|---|---|
| `build_files/build-duress.sh` | Pin + compile pam-duress → `$DESTROOT` (prints pin/date; `PAM_DURESS_COMMIT` override) |
| `build_files/duress/` | Templates (mild + local-clear + aggressive), setup tool, PAM **snippets**, THREAT-MODEL, ENABLE |
| `build.sh.snippet` | Deploy packaging; **no PAM enable** (`DURESS=assets` intent) |
| `Containerfile.snippet` | Optional `duressbuilder` stage |
| `ENABLE.md` | Admin enable / recovery / bootc PAM drift / root-shell checklist |
| `DRILL.md` | PAM-inert path rehearsal (image layout + `--help`/`--dry-run`; not production enable) |
| `FAQ.md` | Operator Q&A (off by default, signing, greeter/lock, lockout, bootc, LUKS residual) |
| `OPERATOR-RUNBOOK.md` | Ordered enable → VM test → disable/rollback (after DRILL) |
| `SIGNING.md` | Local sign / verify workflow; **never** commit `*.sha256`; disposable lab path |
| `RESIDUALS.md` | What packaging does **not** solve; **still OFF** residual |
| `snippet-selftest.sh` | Asserts build/Containerfile snippets stay PAM-inert (+ pam-snippet→`/etc/pam.d` negatives) |
| `validate.sh` | Packaging safety gates + negative fixtures (no `.sha256`, no pam.d writes, W3 N7 snippet copy) |
| `INTEGRATOR-CHECKLIST.md` | **Pre-merge freeze (W4):** merge → snippets → never default-on → validate + duress-safety |
| `INTEGRATION-DAY.md` | **One-page day-of card:** merge D → snippets → validate → never enable PAM |

## Templates (severity — must match `build_files/duress/README.md`)

| File | Severity | Setup flag |
|---|---|---|
| `templates/00-wipe-sensitive.sh` | **AGGRESSIVE** | `--wipe-template` |
| `templates/10-clear-histories.sh` | **MILD** | `--mild-template` |
| `templates/20-local-only-clear.sh` | **MILD** | `--local-clear-template` |

### Operator & integrator docs (index)

| Doc | Use when |
|---|---|
| [INTEGRATION-DAY.md](./INTEGRATION-DAY.md) | **Integration day** one-page gate card (merge → validate → no PAM) |
| [INTEGRATOR-CHECKLIST.md](./INTEGRATOR-CHECKLIST.md) | Full pre-merge freeze checklist |
| [FAQ.md](./FAQ.md) | Scope, off-by-default, greeter/lock, lockout, bootc, LUKS residual |
| [OPERATOR-RUNBOOK.md](./OPERATOR-RUNBOOK.md) | Ordered enable → VM test → disable/rollback |
| [SIGNING.md](./SIGNING.md) | Local `duress_sign` / `--verify`; never commit `*.sha256` |
| [RESIDUALS.md](./RESIDUALS.md) | What packaging does **not** solve |
| [DRILL.md](./DRILL.md) | PAM-inert image-path rehearsal (not enable) |
| [ENABLE.md](./ENABLE.md) | PAM insert details, recovery, bootc drift |

## Setup tool

```bash
hyprwave-duress-setup --dry-run --mild-template
hyprwave-duress-setup --mild-template
hyprwave-duress-setup --local-clear-template
hyprwave-duress-setup --wipe-template
hyprwave-duress-setup --verify
hyprwave-duress-setup --status --json
```

## Validate (pre-merge freeze)

```bash
bash planning/integration/d-duress/snippet-selftest.sh
bash planning/integration/d-duress/validate.sh
```

Both must exit 0. Packaging stays **OFF by default** — no accidental enable path in snippets.

## Integrator merge

Follow **[INTEGRATOR-CHECKLIST.md](./INTEGRATOR-CHECKLIST.md)** end-to-end. Summary:

1. Merge packaging tree (`build_files/duress/**`, `build-duress.sh`, this directory).
2. Apply `Containerfile.snippet` + `build.sh.snippet` (assets only).
3. **Do not** enable PAM / bake `*.sha256` in the same PR.
4. Run `snippet-selftest.sh` + `validate.sh`.
5. Point operators at ENABLE path docs only (runbook / DRILL / SIGNING) — not CI enable.

## Forbidden (kept)

- No production `build.sh` / `Containerfile` edits in this lane (snippets only)
- No default signed scripts / no default PAM lines
- No skel / assistant / product README ownership
- No path to accidental PAM enable at build time
