# Model D Work Log

(append only)

## 2026-08-07 — D-W1-001

- Implemented security review pack on `lane/d-duress` (worktree).
- Added `build_files/duress/THREAT-MODEL.md` (assets, adversaries, residual risks, LUKS/forensics non-goals).
- Added mild template `templates/20-local-only-clear.sh` (`~/.cache` only) + README severity row + `--local-clear-template`.
- Extended `hyprwave-duress-setup` to v1.2.0 with read-only `--verify` (modes + matching `.sha256`).
- `build-duress.sh`: echo pin + UTC date; BUMP-style `PAM_DURESS_COMMIT` override docs.
- `ENABLE.md` (packaging + integration): lockout recovery + bootc PAM drift commands.
- `planning/integration/d-duress/DRILL.md` 30–45 min disposable VM procedure.
- Expanded `validate.sh` (THREAT-MODEL, no `*.sha256`, no default required pam_duress, `--verify` fixtures).
- Commits: e7ccce3, a348bb4, 16535c9 (+ DONE meta).
- `bash planning/integration/d-duress/validate.sh` → PASSED.
