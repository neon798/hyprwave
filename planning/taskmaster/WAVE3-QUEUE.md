# Wave 3 queue (issue when the matching W2-002/003 is DONE)

Wave 2 follow-ups are **fully issued**. Do not double-issue W2 ids.

| Next id | After | Title (exclusive paths only) |
|---|---|---|
| A-W3-001 | A-W2-002 | FIRST-BOOT-CHECKLIST mark local+CI image proofs; GHCR 403 still honest; pin HEAD re-verify |
| B-W3-001 | B-W2-002 | first-boot.md + INSTALL: local `just build` path vs GHCR private; no screenshot binaries |
| C-W3-001 | C-W2-002 | Assistant tests for private-GHCR / dual-DE copy; catalog IDs still real |
| D-W3-001 | D-W2-002 | Extra negative fixture: build.sh must not copy pam snippets to `/etc/pam.d` |
| E-W3-001 | E-W2-002 | SESSION-SMOKE vs `localhost/hyprwave:latest` inspect notes; dwindle comments only |
| F-W3-001 | F-W2-002 | ISO-cosmic.toml operator note + SESSION-SMOKE image-inspect results committed |
| G-W3-001 | G-W2-003 | `check-image.sh --cosmic` PASS on `localhost/hyprwave-cosmic:latest`; residuals VM-only |

Integrator (not a lane): VM qcow2 smokes when A–G W3 is in flight or after.

Keep tasks inside IDENTITY exclusive paths. Never enable duress PAM.
