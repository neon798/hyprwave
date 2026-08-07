# Integration: Model D — Duress (lane/d-duress)

## Wave 1 + Wave 2 delivered

| Artifact | Purpose |
|---|---|
| `build_files/build-duress.sh` | Pin + compile pam-duress → `$DESTROOT` |
| `build_files/duress/` | Templates (mild + aggressive), setup tool, PAM **snippets**, security README, ENABLE.md |
| `build.sh.snippet` | Deploy packaging; **no PAM enable** (`DURESS=assets` intent) |
| `Containerfile.snippet` | Optional `duressbuilder` stage |
| `ENABLE.md` | Admin enable / rollback / Atomic notes / root-shell checklist |
| `validate.sh` | Packaging safety gates (syntax, no `.sha256`, no pam.d writes) |

## Setup tool (Wave 2)

```bash
hyprwave-duress-setup --dry-run --mild-template
hyprwave-duress-setup --mild-template
hyprwave-duress-setup --wipe-template
hyprwave-duress-setup --status --json
```

## Validate

```bash
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
