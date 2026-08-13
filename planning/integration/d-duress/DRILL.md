# Disposable VM drill — Hyprwave duress (operator procedure)

**Duration:** 30–45 minutes  
**Goal:** Prove packaging is inert by default, that opt-in sign + mild clear works,
and that you can recover from a bad PAM edit — **without** using a daily driver.

**Default remains OFF.** This drill never belongs in CI image defaults.

## Prerequisites

- Disposable VM (qcow2 / ISO) of Hyprwave **or** a throwaway user on a lab box
- Root console path: second TTY, serial, or `sudo -i` left open
- Image has (or you bind-mount) packaging assets:
  - `pam_duress.so`, `duress_sign`, `hyprwave-duress-setup`
  - templates under `/usr/share/hyprwave/duress/templates/`
- Clock: 30–45 minutes blocked; do not rush PAM edits

If binaries are not in the image yet, stop after **Phase A** packaging checks on the
host/repo and schedule an integrator build before Phases B–D.

## Phase A — Stock / packaging (5 min)

| Step | Action | Pass criteria |
|---|---|---|
| A1 | On **repo host**: `bash planning/integration/d-duress/validate.sh` | Exit 0 |
| A2 | In VM (if assets present): `hyprwave-duress-setup --status` | Reports PAM OFF / no enable lines expected |
| A3 | `hyprwave-duress-setup --verify` | OK empty or OK with no issues; **read-only** |
| A4 | Confirm no login change with normal password | Session works as before enable |

**Stop if validate fails.** Do not enable PAM on a broken tree.

## Phase B — Mild opt-in without PAM (8 min)

| Step | Action | Pass criteria |
|---|---|---|
| B1 | `hyprwave-duress-setup --dry-run --mild-template` | Dry-run messages; no `~/.duress/*.sha256` |
| B2 | `hyprwave-duress-setup --mild-template` | Prompts; produces signed script mode 500 + `.sha256` mode 400 |
| B3 | `hyprwave-duress-setup --verify` | RESULT OK for signed mild script |
| B4 | Optional: `--dry-run --local-clear-template` | Previews `20-local-only-clear.sh` only |

Still **no** PAM line. Normal password must not run duress scripts.

## Phase C — Enable PAM carefully (10–12 min)

Keep **root shell open** for the entire phase.

| Step | Action | Pass criteria |
|---|---|---|
| C1 | `sudo cp -a /etc/pam.d/system-auth "/etc/pam.d/system-auth.bak.$(date +%Y%m%d%H%M%S)"` | Backup exists |
| C2 | Insert `auth sufficient pam_duress.so` **after** `pam_unix` (see `ENABLE.md`) | Prefer `sufficient`, never start with `required` |
| C3 | `hyprwave-duress-setup --status` | Shows PAM reference in expected file |
| C4 | Login / unlock with **normal** password | Success; mild clear **does not** run (or no unwanted loss) |
| C5 | Login / unlock with **duress** password | Success; mild clear runs; no error UI / “duress mode” banner |
| C6 | Wrong password | Fail as usual |

If C4 fails: **immediately** restore backup from the open root shell (Phase D).

## Phase D — Recovery rehearsal (5–8 min)

Practice lockout recovery **while you still have root**, even if nothing broke.

| Step | Action | Pass criteria |
|---|---|---|
| D1 | From root: restore `system-auth` from `.bak.*` **or** delete only the `pam_duress.so` line | File valid |
| D2 | `grep pam_duress /etc/pam.d/system-auth` (or greeter file) | No unexpected enable, or intentional remaining line documented |
| D3 | Login with normal password | Success |
| D4 | `hyprwave-duress-setup --remove 10-clear-histories.sh` (optional cleanup) | Script + sig gone |
| D5 | `hyprwave-duress-setup --verify` | Empty OK or remaining scripts OK |

### If you are locked out (real failure)

1. Boot recovery / live USB / single-user if available on the lab image.
2. Mount the system root; edit `/etc/pam.d/system-auth` (or the greeter file you changed).
3. Remove `pam_duress.so` lines or restore from `*.bak.*`.
4. Reboot; confirm normal login.
5. File notes: which file was edited, which control flag was used (`required` is a common footgun).

## Phase E — Upgrade drift awareness (3–5 min)

| Step | Action | Pass criteria |
|---|---|---|
| E1 | Read `ENABLE.md` bootc upgrade section | Operator knows PAM may reset |
| E2 | Simulate check: `grep -n pam_duress /etc/pam.d/system-auth \|\| true` | Command memorized for post-`bootc upgrade` |
| E3 | Document whether your lab re-applies the line after upgrade | Written note for your runbook |

Do **not** require a full `bootc upgrade` inside the 45-minute window if bandwidth is limited; the check command is mandatory knowledge.

## Aggressive template (optional, +10 min)

Only on a **throwaway account** with no valued data:

```bash
hyprwave-duress-setup --wipe-template
# then duress login once; confirm keys/profiles gone; delete account afterward
```

Prefer stopping after mild success for first drills.

## Pass / fail summary

**PASS** when:

- validate.sh green on packaging host
- Stock state inert before PAM enable
- Normal password always works when using `sufficient`
- Duress password runs expected mild script once signed + PAM enabled
- Recovery path demonstrated from root shell

**FAIL** when:

- Any default image path enables PAM without human edit
- `required pam_duress` used without recovery plan
- Pre-signed `*.sha256` found in packaging tree
- Operator cannot restore PAM from backup

## References

- `planning/integration/d-duress/ENABLE.md`
- `build_files/duress/THREAT-MODEL.md`
- `build_files/duress/README.md`
- Upstream: https://github.com/nuvious/pam-duress
