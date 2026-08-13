# Disposable VM drill — Hyprwave duress (operator **rehearsal**)

**Duration:** 30–45 minutes (safe path is ~15–25 min)  
**Goal:** Walk **real image paths** and prove packaging is inert by default —
module present, scripts unsigned, **PAM OFF** — using only `--help`, `--status`,
`--verify`, and `--dry-run`.

---

## BANNER — rehearsal only (read first)

| This drill **does** | This drill **does not** |
|---|---|
| Inventory stock image paths | Edit `/etc/pam.d/*` |
| Run `hyprwave-duress-setup --help` / `--status` / `--verify` / `--dry-run` | Install `pam_duress` into any live PAM stack |
| Optional: sign a **mild** user script (still PAM OFF) | Enable production duress authentication |
| Confirm `/etc/duress.d` is empty of scripts | Bake or commit `*.sha256` |

**Default remains OFF.** This drill is a **rehearsal**, not production enablement.  
Production enable stays **operator-only** after a green drill — see `ENABLE.md` and
`OPERATOR-RUNBOOK.md` §3+. **Never** put a `pam_duress.so` line into `/etc/pam.d`
during this procedure. CI image defaults must never enable PAM.

---

## Stock image layout (match these paths)

Paths reflect the Wave 2 Hyprwave image (`localhost/hyprwave:latest` inspect
2026-08-13) and `build.sh` / `build.sh.snippet` install targets. On Fedora
usr-merge systems, `/usr/bin` is the install path (not `/usr/sbin`).

| Path | Stock state |
|---|---|
| `/usr/lib64/security/pam_duress.so` | Present (module ships) |
| `/usr/bin/hyprwave-duress-setup` | Present (opt-in tool; mode `0755`) |
| `/usr/bin/duress_sign` | Present (signing helper; used only if you sign) |
| `/usr/share/hyprwave/duress/` | Docs + assets root (`README.md`, `ENABLE.md`, …) |
| `/usr/share/hyprwave/duress/templates/` | Unsigned templates (`00`/`10`/`20-*.sh`) |
| `/usr/share/hyprwave/duress/pam.d/*.snippet` | **Reference only** — not live PAM |
| `/etc/duress.d/` | Exists; **README only** (no scripts, no `*.sha256`) |
| `/etc/pam.d/*` | **Zero** `pam_duress` lines |
| `~/.duress/` | Absent until a user runs setup |

If a binary is missing, stop after **Phase A** (repo host) and schedule an image
rebuild — do not invent alternate PAM enable paths.

---

## Prerequisites

- Disposable VM (qcow2 / ISO) of Hyprwave **or** a throwaway user on a lab box
- Optional root console for inspect-only commands (`ls`, `grep`) — **not** for PAM edits
- Clock: 30–45 minutes blocked if you include optional signing; shorter for dry-run only

---

## Phase A — Repo packaging host (5 min)

Run on the **git checkout** (no VM required):

| Step | Action | Pass criteria |
|---|---|---|
| A1 | `bash planning/integration/d-duress/validate.sh` | `RESULT: PASSED` |
| A2 | `bash planning/qa/run-all.sh --only duress-safety` | Check PASS / RESULT OK |
| A3 | `bash build_files/duress/hyprwave-duress-setup --help` | Mentions **OFF BY DEFAULT** / operator |
| A4 | Confirm no packaging `*.sha256` | `find build_files/duress planning/integration/d-duress -name '*.sha256'` empty |

**Stop if validate or duress-safety fails.** Do not proceed to a VM enable fantasy.

---

## Phase B — Image path inventory (5–8 min)

On the **installed image / disposable VM** (read-only checks):

| Step | Action | Pass criteria |
|---|---|---|
| B1 | `test -x /usr/bin/hyprwave-duress-setup && command -v hyprwave-duress-setup` | Tool on PATH via `/usr/bin` |
| B2 | `ls -la /usr/lib64/security/pam_duress.so` | Module file present |
| B3 | `ls -la /usr/share/hyprwave/duress/ /usr/share/hyprwave/duress/templates/` | Docs + unsigned templates |
| B4 | `ls -la /etc/duress.d/` | README present; **no** `*.sh` / `*.sha256` |
| B5 | `grep -RIn 'pam_duress' /etc/pam.d 2>/dev/null \|\| echo 'OK: no pam_duress'` | No enable lines |
| B6 | `test ! -e /usr/share/hyprwave/duress/pam.d/*.snippet \|\| ls /usr/share/hyprwave/duress/pam.d/` | Snippets only under share (not `/etc/pam.d`) |

---

## Phase C — Dry-run / help / status / verify only (8–10 min)

**No PAM edits. Prefer `--dry-run` before any sign.**

| Step | Action | Pass criteria |
|---|---|---|
| C1 | `hyprwave-duress-setup --help` | OFF BY DEFAULT; does not claim to enable PAM |
| C2 | `hyprwave-duress-setup --status` | Reports PAM OFF / no enable lines (stock) |
| C3 | `hyprwave-duress-setup --verify` | OK empty or OK with no issues; **read-only** |
| C4 | `hyprwave-duress-setup --dry-run --mild-template` | Dry-run banner; **no** `~/.duress/*.sha256` written |
| C5 | Optional: `hyprwave-duress-setup --dry-run --local-clear-template` | Previews `20-local-only-clear.sh` only |
| C6 | Optional: `hyprwave-duress-setup --status --json` | `"pam_enabled":false`, `"stock_default":"OFF"` |

Still **no** PAM line. Normal password login must be unchanged.

---

## Phase D — Optional mild sign (still PAM OFF) (5–8 min)

Only if you want to practice signing **without** enabling authentication:

| Step | Action | Pass criteria |
|---|---|---|
| D1 | `hyprwave-duress-setup --mild-template` | Prompts; mode `500` script + `400` `.sha256` under `~/.duress/` |
| D2 | `hyprwave-duress-setup --verify` | RESULT OK for signed mild script |
| D3 | Login / unlock with **normal** password | Success; mild clear **does not** run (PAM still OFF) |
| D4 | Optional cleanup: `hyprwave-duress-setup --remove 10-clear-histories.sh` | Script + sig gone |

Signing alone does **nothing** at login until an admin follows `ENABLE.md`.

---

## STOP — production enable is out of this drill

**Do not continue into PAM edits as part of this drill.**

When (and only when) you intentionally enable on a disposable VM later:

1. Read `/usr/share/hyprwave/duress/ENABLE.md` (or `planning/integration/d-duress/ENABLE.md`).
2. Follow `OPERATOR-RUNBOOK.md` §3–§5 with an open root shell and timestamped backups.
3. Prefer `auth sufficient pam_duress.so` after `pam_unix`; never start with `required`.
4. Rehearse recovery **before** you need it (runbook §5 / ENABLE recovery section).

Those steps are **operator production enablement**, not the Wave 2 path drill.

---

## Aggressive template (optional lab only — still no PAM)

Only on a **throwaway account** with no valued data, and still **without** PAM enable
unless you have left this drill for full runbook enable:

```bash
hyprwave-duress-setup --dry-run --wipe-template
# review targets carefully before any real sign
```

Prefer stopping after mild dry-run / mild sign for first drills.

---

## Pass / fail summary

**PASS** when:

- `validate.sh` and `duress-safety` green on packaging host
- Image paths match the stock layout table above
- Stock state inert: zero `/etc/pam.d` `pam_duress` lines; `/etc/duress.d` script-empty
- Drill used only help / status / verify / dry-run (optional user sign); **no** PAM install
- Normal password still works; signed scripts do not run while PAM is OFF

**FAIL** when:

- Any default image path enables PAM without human edit
- Drill instructions or operator action write `pam_duress` into `/etc/pam.d`
- Pre-signed `*.sha256` found in packaging tree or stock `/etc/duress.d`
- Paths in docs do not match `/usr/bin/hyprwave-duress-setup`, `/usr/share/hyprwave/duress`, `/etc/duress.d`

---

## References

- Image-local enable (operator only): `/usr/share/hyprwave/duress/ENABLE.md`
- Repo: `planning/integration/d-duress/ENABLE.md`
- `planning/integration/d-duress/OPERATOR-RUNBOOK.md` (enable → test → rollback)
- `planning/integration/d-duress/RESIDUALS.md` (still OFF residual)
- `planning/integration/d-duress/SIGNING.md`
- `build_files/duress/THREAT-MODEL.md`
- `build_files/duress/README.md`
- Upstream: https://github.com/nuvious/pam-duress
