# Threat model: Hyprwave duress packaging

**Status:** packaging / documentation only. Stock images keep **PAM OFF BY DEFAULT**.  
This document describes what the opt-in duress subsystem can and cannot do.
It is not a product security guarantee.

## Assets

| Asset | Why it matters | How duress may touch it |
|---|---|---|
| User session authenticity at greeter / lock | Coercer watches typing | Alternate password still grants a session |
| Secrets under `$HOME` (SSH, GPG, keyrings) | Immediate value under coercion | Aggressive template best-effort wipe |
| Browser profiles / cookies / session caches | Account takeover / session theft | Aggressive wipe or local-only clear |
| Shell / clipboard histories | Breadcrumbs of recent work | Mild template clear |
| Signed duress script set (`~/.duress`, `/etc/duress.d`) | Defines what runs under duress | User/admin signs with `duress_sign` |
| PAM stack integrity | Login availability for everyone | Human enable only; prefer `sufficient` |
| Image immutability (bootc) | Predictable baseline | Build stages binaries only; no PAM rewrite |

## Adversaries

| Adversary | Capabilities | Duress goal |
|---|---|---|
| **Live coercer** | Watches user unlock; may demand “the password”; limited time on device | User enters duress password; session looks normal; scripts run quietly |
| **Curious peer / shoulder-surfer** | Sees unlock succeed; may poke the UI | No “duress mode” banner; mild clears reduce visible history |
| **Local account peer** | Same machine, no root | User scripts in `~/.duress` only affect that user’s data |
| **Malicious admin / root** | Full control of PAM, packages, disk | **Out of scope** — they can disable, re-sign, or image the disk |
| **Offline forensic examiner** | Disk image, cold storage, lab tools | **Out of scope** — residual data may remain; not secure erase |
| **Network observer** | Watches traffic after login | **Non-goal** as default — no phone-home by design (timing/logs risk) |

## Trust boundaries

1. **Build time:** `build-duress.sh` compiles pinned upstream into staging (`DESTROOT`). No host PAM edits.
2. **Image ship:** binaries + **unsigned** templates + docs. Empty `/etc/duress.d`. No `*.sha256` in tree.
3. **Admin enable:** human edits `/etc/pam.d` per `ENABLE.md`. Prefer `sufficient` after `pam_unix`.
4. **User opt-in:** `hyprwave-duress-setup` copies a template and runs `duress_sign` interactively.
5. **Runtime:** `pam_duress.so` matches signed salt hashes; runs scripts with modes `500`/`540`/`550`.

Anything before step 3 is intentionally inert.

## In-scope goals

- Raise cost of **live coercion** at password entry (greeter / lock).
- Keep stock behavior identical when PAM is off and no scripts are signed.
- Offer graded responses: mild history clear, local-only browser cache clear, aggressive wipe.
- Fail as safely as practical: missing module + `required` can lock out; docs push `sufficient`.
- Give operators verify tooling (`--verify`, `validate.sh`) so packaging stays honest.

## Explicit non-goals

| Non-goal | Rationale |
|---|---|
| **LUKS / full-disk crypto substitute** | Duress runs after a successful auth path; it does not replace volume keys |
| **Forensic-grade wipe** | `shred`/rm is best-effort; SSDs, journals, snapshots, and prior images remain |
| **Convincing a prepared attacker** | Someone who already knows duress exists may demand both passwords or image first |
| **Default network exfil / “phone home”** | Timing, DNS, and logs can *confirm* duress was used |
| **Multi-user shared default password** | Never ship a common duress secret or pre-signed scripts |
| **Automatic PAM enable in CI/image** | Lockout and policy risk; human procedure only |
| **Defeat root / evil maid with disk access** | Physical possession + root wins |

## Residual risks

1. **PAM lockout:** `required pam_duress.so` with a missing `.so` or broken stack can lock all users. Mitigation: `sufficient`, open root shell, backups, recovery section in `ENABLE.md`.
2. **bootc / package PAM drift:** upgrades may restore vendor `system-auth` and silently drop the duress line (or reintroduce conflicting lines). Mitigation: re-check after `bootc upgrade` (see `ENABLE.md`).
3. **Incomplete wipe:** aggressive template lists common paths only; custom secret locations survive.
4. **Script bugs:** a signed script can destroy wanted data or fail silently; test in a disposable VM (`DRILL.md`).
5. **Signature theft:** if an attacker obtains both script and `.sha256` plus password knowledge, they can forge behavior offline — operational secret hygiene still required.
6. **Side channels:** log lines via `systemd-cat`, missing files, or timing may leak that something unusual ran.
7. **Social:** under stress, users may enter the wrong password class or reveal both secrets.

## Severity of shipped templates

| Template | Severity | Intended effect |
|---|---|---|
| `10-clear-histories.sh` | MILD | Shell/recent histories + clipboard |
| `20-local-only-clear.sh` | MILD | Browser **session cache** under one cache root only |
| `00-wipe-sensitive.sh` | AGGRESSIVE | Keys, profiles, common secrets |

All remain **unsigned** in the package tree.

## Acceptable failure modes

| Condition | Desired behavior |
|---|---|
| Stock image, no PAM line | Normal auth only |
| PAM enabled, no signed scripts | Module ignores; normal passwords work |
| Bad mode or missing `.sha256` | Script ignored by upstream rules |
| Duress password used | Session succeeds; scripts run in background |
| Module missing + `sufficient` | Fall through; login still possible via unix |
| Module missing + `required` | **Dangerous** — may deny all; avoid |

## Validation & operator checks

- Repo: `planning/integration/d-duress/validate.sh` (packaging safety).
- Host (after opt-in): `hyprwave-duress-setup --verify` (modes + matching `.sha256`).
- Procedure: `planning/integration/d-duress/DRILL.md` (disposable VM).

## Related docs

- `README.md` — packaging overview
- `ENABLE.md` — admin enable, recovery, upgrade drift
- `planning/integration/d-duress/ENABLE.md` — full integrator procedure
- Upstream: https://github.com/nuvious/pam-duress
