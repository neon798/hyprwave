# Hyprwave Duress Password (packaging)

**Status in image:** assets may be shipped; **PAM is OFF BY DEFAULT**.  
Nothing runs at login until (1) the integrator enables `pam_duress.so` in the
relevant PAM stacks, **and** (2) a user (or admin) signs at least one script with
`duress_sign` / `hyprwave-duress-setup`.

This directory is the self-contained source of truth for the duress subsystem.
Production wiring lives in `planning/integration/d-duress/` until a human
enables it.

## What this is

A **duress password** is an alternate password that:

1. Still authenticates (session looks normal to a coercer).
2. Runs signed scripts in the background (e.g. wipe sensitive paths).
3. Does **not** use the user’s real password hash — matching is via
   per-script signed salt hashes from [nuvious/pam-duress](https://github.com/nuvious/pam-duress).

Implementation module: `pam_duress.so` + `duress_sign` (upstream).

## Threat model (short)

| Goal | In scope | Out of scope |
|---|---|---|
| Coercion at login / unlock where the attacker watches the user type a password | Yes | Full disk forensics after imaging |
| Offline wipe of common secrets under `$HOME` | Yes | Secure erase of whole disk / LUKS |
| Silent success (no “duress mode” UI) | Yes | Convincing a skilled attacker who already knows duress exists |
| Immutable bootc image with opt-in user config | Yes | Network “phone home” as default (risky timing/logs) |

**This is not magic.** A sophisticated attacker with:

- prior knowledge that duress is installed,
- a disk image / live USB forensics kit,
- or control of the machine before you set it up,

can still recover data or notice missing files. Duress raises the cost of
*live coercion*; it does not replace encryption, good operational security, or
legal advice.

### Fail-closed / fail-safe behavior

- **Module missing:** if PAM is enabled but `pam_duress.so` is absent, a
  misconfigured stack can lock users out. Enable only with the documented
  `sufficient` placement after `pam_unix` (see `ENABLE.md`). Prefer
  `sufficient` over `required` for the duress line so a missing module does not
  brick login when using the RH-style stack.
- **No signed scripts:** `pam_duress` returns ignore; normal passwords still
  work. Duress passwords do nothing until something is signed — **by design**
  on a stock Hyprwave image.
- **Unsigned or wrong-mode scripts:** ignored. Upstream requires script modes
  `500`, `540`, or `550`.
- **Stock image:** no passwords signed, no PAM line enabled → **zero behavior
  change**.

## Layout

| Path (in repo) | Runtime path (after integration) | Role |
|---|---|---|
| `build_files/build-duress.sh` | (builder only) | Compile/pin pam-duress into `/install` |
| `build_files/duress/hyprwave-duress-setup` | `/usr/bin/hyprwave-duress-setup` | Opt-in user setup |
| `build_files/duress/templates/00-wipe-sensitive.sh` | `/usr/share/hyprwave/duress/templates/…` | **Template only** — not auto-signed |
| `build_files/duress/pam.d/*.snippet` | (docs; applied only when enabling) | Reference PAM fragments |
| empty dir created at build | `/etc/duress.d/` | Global scripts (root); empty until admin signs |
| (user creates) | `~/.duress/` | Per-user scripts (upstream path; **not** `~/.duress.d`) |

Upstream env for scripts: **`PAMUSER`** (username that triggered duress).

## Login managers & locks

| Path | PAM consumer | Notes |
|---|---|---|
| **SDDM** (Hyprland variant) | `/etc/pam.d/sddm` → often includes `system-auth` | Prefer enabling on `system-auth` once (covers many services) **or** only on `sddm` for greeter-only. |
| **cosmic-greeter / greetd** (COSMIC) | `/etc/pam.d/greetd` (or distro-specific) | Same module; test after enable. |
| **hyprlock** | typically `/etc/pam.d/hyprlock` or `login` / `system-auth` | Uses PAM → works once the stack that hyprlock calls includes `pam_duress`. |

Exact enable steps: `planning/integration/d-duress/ENABLE.md`.

## Opt-in flow (users)

```bash
hyprwave-duress-setup
# or: hyprwave-duress-setup --help
```

The setup tool:

1. Warns about irreversible wipes.
2. Copies the wipe **template** into `~/.duress/` (only if you confirm).
3. Runs `duress_sign` so **you** choose the duress password.
4. Sets permissions to modes pam-duress accepts.

It does **not** enable system PAM. That remains an admin/integrator action.

## Build / pin

- Upstream: `https://github.com/nuvious/pam-duress`
- Pin: commit `1f699c157fbafd03c48032661d5f15f87e8efd13` (main as of 2026-07-16)
- Fedora install path for `.so`: `/usr/lib64/security` (`PAM_DIR`)
- Builder script: `build_files/build-duress.sh` (mirrors `build-hypr-utils.sh` DESTROOT pattern)

## Legal / ethics

Duress tooling can destroy data or conceal activity. Operators are responsible
for lawful use. Do not enable on multi-user machines without clear policy.
Do not treat this as a substitute for professional security advice.

## References

- https://github.com/nuvious/pam-duress
- `planning/DURESS-PASSWORD.md`
- `planning/integration/d-duress/ENABLE.md`
