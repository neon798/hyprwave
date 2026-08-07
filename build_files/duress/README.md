# Hyprwave Duress Password (packaging)

**Status in image:** assets may be shipped; **PAM is OFF BY DEFAULT**.  
Nothing runs at login until (1) an administrator enables `pam_duress.so` in the
relevant PAM stacks, **and** (2) a user (or admin) signs at least one script with
`duress_sign` / `hyprwave-duress-setup`.

This directory is the self-contained source of truth for the duress subsystem.
Production wiring lives in `planning/integration/d-duress/` until a human
applies snippets. **There is no supported in-image `DURESS=enable` build mode.**

## What this is

A **duress password** is an alternate password that:

1. Still authenticates (session looks normal to a coercer).
2. Runs signed scripts in the background (e.g. wipe sensitive paths).
3. Does **not** use the user’s real password hash — matching is via
   per-script signed salt hashes from [nuvious/pam-duress](https://github.com/nuvious/pam-duress).

Implementation module: `pam_duress.so` + `duress_sign` (upstream).

## Templates (severity)

| File | Severity | What it does | Setup flag |
|---|---|---|---|
| `templates/00-wipe-sensitive.sh` | **AGGRESSIVE** | Best-effort destroy of keys, keyrings, browser profiles, common secrets | `--wipe-template` |
| `templates/10-clear-histories.sh` | **MILD** | Shell histories + clipboard only | `--mild-template` |
| `templates/20-local-only-clear.sh` | **MILD** | Browser/session caches under `~/.cache` only (single root) | `--local-clear-template` |

All are **unsigned** in the package tree. Prefer MILD unless you need more.
Never bake `.sha256` signature files into the image or git tree.

```bash
hyprwave-duress-setup --dry-run --mild-template          # preview only
hyprwave-duress-setup --mild-template                    # install + sign (needs duress_sign)
hyprwave-duress-setup --local-clear-template             # mild cache clear
hyprwave-duress-setup --verify                           # read-only: modes + matching .sha256
hyprwave-duress-setup --status --json
```

## Threat model

Formal model: **`THREAT-MODEL.md`** (assets, adversaries, residual risks, non-goals:
LUKS, forensics). Short summary:

| Goal | In scope | Out of scope |
|---|---|---|
| Coercion at login / unlock where the attacker watches the user type a password | Yes | Full disk forensics after imaging |
| Offline wipe or clear of selected paths under `$HOME` | Yes | Secure erase of whole disk / LUKS |
| Silent success (no “duress mode” UI) | Yes | Convincing a skilled attacker who already knows duress exists |
| Immutable bootc image with opt-in user config | Yes | Network “phone home” as default (risky timing/logs) |

**This is not magic.** A sophisticated attacker with prior knowledge, a disk image,
or pre-setup control of the machine can still recover data. Duress raises the cost
of *live coercion*; it does not replace encryption or operational security.

### Fail-closed / fail-safe behavior

- **Module missing:** if PAM is enabled but `pam_duress.so` is absent, a
  misconfigured stack can lock users out. Enable only with documented
  **`sufficient`** placement after `pam_unix` (see `ENABLE.md`).
- **No signed scripts:** `pam_duress` returns ignore; normal passwords still work.
- **Unsigned or wrong-mode scripts:** ignored. Upstream requires modes
  `500`, `540`, or `550`.
- **Stock image:** no passwords signed, no PAM line enabled → **zero behavior change**.

## Layout

| Path (in repo) | Runtime path (after integration) | Role |
|---|---|---|
| `build_files/build-duress.sh` | (builder only) | Compile/pin pam-duress into `/install` |
| `build_files/duress/hyprwave-duress-setup` | `/usr/bin/hyprwave-duress-setup` | Opt-in user setup (`--dry-run`, `--json`, …) |
| `build_files/duress/templates/*.sh` | `/usr/share/hyprwave/duress/templates/…` | **Templates only** — not auto-signed |
| `build_files/duress/pam.d/*.snippet` | docs only | Reference PAM fragments |
| empty dir created at build | `/etc/duress.d/` | Global scripts; empty until admin signs |
| (user creates) | `~/.duress/` | Per-user scripts (upstream path; **not** `~/.duress.d`) |

Upstream env for scripts: **`PAMUSER`**.

## Login managers & locks

| Path | Notes |
|---|---|
| **SDDM** (Hyprland) | Often includes `system-auth` — one edit can cover greeter + more |
| **cosmic-greeter / greetd** | Check `/etc/pam.d/greetd` (and `cosmic-greeter` if present) |
| **hyprlock** | PAM; inherits system-auth when included |

Exact enable steps: `ENABLE.md` / `planning/integration/d-duress/ENABLE.md`.

## Build / pin

- Upstream: `https://github.com/nuvious/pam-duress`
- Pin: commit `1f699c157fbafd03c48032661d5f15f87e8efd13` (see bump notes in `build-duress.sh`)
- Fedora `.so` path: `/usr/lib64/security`
- Validate packaging: `planning/integration/d-duress/validate.sh`

## Legal / ethics

Duress tooling can destroy data or conceal activity. Operators are responsible
for lawful use. Do not enable on multi-user machines without clear policy.

## References

- https://github.com/nuvious/pam-duress
- `planning/DURESS-PASSWORD.md`
- `planning/integration/d-duress/INTEGRATION-DAY.md` — integration-day one-page gate card
- `planning/integration/d-duress/INTEGRATOR-CHECKLIST.md` — pre-merge freeze (assets only)
- `planning/integration/d-duress/ENABLE.md`
- `planning/integration/d-duress/FAQ.md`
- `planning/integration/d-duress/OPERATOR-RUNBOOK.md`
- `planning/integration/d-duress/SIGNING.md` — local sign/verify; never commit `*.sha256`
- `planning/integration/d-duress/RESIDUALS.md` — residual operator duties
- `planning/integration/d-duress/DRILL.md`
- `planning/PARALLEL-WAVE2-OVERNIGHT.md` § MODEL D
