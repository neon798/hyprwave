# Integration: Model D — Duress (lane/d-duress)

## Delivered in this branch

| Artifact | Purpose |
|---|---|
| `build_files/build-duress.sh` | Pin + compile pam-duress → `$DESTROOT` |
| `build_files/duress/` | Templates, setup tool, PAM **snippets**, security README, ENABLE.md |
| `build.sh.snippet` | Deploy packaging; **no PAM enable** |
| `Containerfile.snippet` | Optional `duressbuilder` stage |
| `ENABLE.md` | Exact admin enable / rollback / test plan |

## Integrator merge order

1. Land Model A (pins) if concurrent.
2. Apply `Containerfile.snippet` + `build.sh.snippet`.
3. Build both variants; confirm `/usr/bin/hyprwave-duress-setup` and module path.
4. **Do not** enable PAM in the same PR unless product + security explicitly want it.
5. Document enable as optional admin procedure only.

## Validation already run on this lane

- `bash -n` on setup tool and wipe template
- `shellcheck` if available (non-blocking)

## Forbidden (kept)

- No edits to live skel, themes, assistant, or production `build.sh` / `Containerfile` in this lane
- No default signed scripts
- No default PAM lines
