# Integration-day gate card — Model D (duress)

**One page. Assets only. PAM stays OFF.**

Full procedure: **[INTEGRATOR-CHECKLIST.md](./INTEGRATOR-CHECKLIST.md)**  
Never ship signatures: **[SIGNING.md](./SIGNING.md)** (“do not commit `*.sha256`”)

---

## Gate order (do in sequence)

| # | Gate | Command / action | Pass |
|---|---|---|---|
| 1 | **Merge D tree** | Land `build_files/build-duress.sh`, `build_files/duress/**`, `planning/integration/d-duress/**` | No skel/assistant/handbook drive-bys |
| 2 | **Apply snippets** | Paste `Containerfile.snippet` + `build.sh.snippet` (assets only) | No edits to live `/etc/pam.d` |
| 3 | **Snippet inert** | `bash planning/integration/d-duress/snippet-selftest.sh` | Exit 0 |
| 4 | **Validate green** | `bash planning/integration/d-duress/validate.sh` | Exit 0 / `RESULT: PASSED` |
| 5 | **No signatures** | `find build_files/duress planning/integration/d-duress -name '*.sha256'` | Empty |
| 6 | **Never enable PAM** | Do **not** add `auth … pam_duress.so` in image/CI | Stock login unchanged |
| 7 | **Operator path only** | Link ENABLE/runbook/DRILL/SIGNING for humans post-boot | No `DURESS=enable` build mode |

---

## Hard no

- Enabling `pam_duress` in shipped PAM defaults  
- Committing or baking `*.sha256` (see **SIGNING.md**)  
- Installing reference `pam.d/*.snippet` over vendor stacks  
- “Just for CI” PAM enable  

---

## Copy-paste

```bash
# After merge + snippet apply
bash planning/integration/d-duress/snippet-selftest.sh
bash planning/integration/d-duress/validate.sh
find build_files/duress planning/integration/d-duress -name '*.sha256'   # must be empty
```

If any gate fails: **stop**. Do not enable PAM. Fix packaging, re-run gates.

---

## After green (not today unless product asks)

Post-boot human only: [OPERATOR-RUNBOOK.md](./OPERATOR-RUNBOOK.md) → [DRILL.md](./DRILL.md) → [ENABLE.md](./ENABLE.md)  
Residual risks operators still own: [RESIDUALS.md](./RESIDUALS.md)
