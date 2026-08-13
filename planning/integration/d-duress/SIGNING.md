# Operator signing workflow (no signatures in git or image)

**Default remains OFF.** This document covers **signing scripts on a machine**,
not enabling PAM. Signatures (`*.sha256`) are **local secrets of the password
binding** — never commit them, never bake them into bootc layers.

Related: `FAQ.md` · `OPERATOR-RUNBOOK.md` · `ENABLE.md` · `RESIDUALS.md` ·
`hyprwave-duress-setup --help`

---

## What a “signature” is here

Upstream `duress_sign` writes a **per-script** file next to the script:

```text
~/.duress/10-clear-histories.sh          # mode 500 / 540 / 550
~/.duress/10-clear-histories.sh.sha256   # mode 400 (typical)
```

The `.sha256` is **not** a public checksum of the script alone — it binds the
script to the **duress password** you type into `duress_sign`. Shipping a
pre-signed tree would also ship a shared secret material path; Hyprwave forbids
that in packaging.

---

## Rules (non-negotiable)

| Rule | Why |
|---|---|
| Never `git add` / commit `*.sha256` | Secrets + password-bound material |
| Never COPY signatures into the image | Stock must stay inert |
| Prefer `hyprwave-duress-setup --dry-run` first | No writes, no `duress_sign` |
| Prefer MILD templates first | Limits blast radius |
| Test in a disposable path or VM | Aggressive templates destroy data |
| PAM enable is separate | Signing alone does not change login |

Repo gate: `planning/integration/d-duress/validate.sh` fails if packaging trees
contain any `*.sha256`.

---

## Path A — Recommended (setup tool)

### 1. Dry-run (no install, no sign)

```bash
hyprwave-duress-setup --dry-run --mild-template
hyprwave-duress-setup --dry-run --local-clear-template
# aggressive only after deliberate review:
# hyprwave-duress-setup --dry-run --wipe-template
```

Expect dry-run messages on **stderr**; no new files under `~/.duress/`.

### 2. Install + sign (interactive)

```bash
hyprwave-duress-setup --mild-template
# or: --local-clear-template
# or: --wipe-template   # AGGRESSIVE — disposable VM only first
```

You will be prompted by `duress_sign` for the **duress** password (not your
normal login password). Choose something distinct.

### 3. Verify (read-only)

```bash
hyprwave-duress-setup --verify
hyprwave-duress-setup --json --verify
hyprwave-duress-setup --status
```

**Success path:** scripts mode `500`/`540`/`550`, matching `*.sha256` present and
readable. `--verify` does **not** re-check crypto without the password; it
checks packaging hygiene (modes + name pairing). Empty dir → OK.

### 4. List / remove

```bash
hyprwave-duress-setup --list
hyprwave-duress-setup --remove 10-clear-histories.sh
```

---

## Path B — Disposable directory (worked example)

Use this when you want to practice signing **without** touching `~/.duress` or
when `duress_sign` is available but you are still on a lab host.

```bash
# Disposable target (never under the git tree)
LAB="${TMPDIR:-/tmp}/hyprwave-duress-lab-$$"
mkdir -p "$LAB"
chmod 700 "$LAB"

# Copy an unsigned template into the lab dir
TPL=/usr/share/hyprwave/duress/templates/10-clear-histories.sh
# From a repo checkout without image install:
# TPL=build_files/duress/templates/10-clear-histories.sh
cp -a "$TPL" "$LAB/10-clear-histories.sh"
chmod 500 "$LAB/10-clear-histories.sh"

# Sign in place (prompts for duress password)
duress_sign "$LAB/10-clear-histories.sh"
chmod 400 "$LAB/10-clear-histories.sh.sha256"

# Read-only verify via setup tool (modes + matching name)
hyprwave-duress-setup --verify "$LAB"

# Prove repo packaging still has zero signatures
find build_files/duress planning/integration/d-duress -name '*.sha256' 2>/dev/null \
  | grep . && echo "FAIL: signatures leaked into packaging" || echo "OK: packaging clean"

# Cleanup lab (including the local signature)
rm -rf "$LAB"
```

**Do not** run the above copy steps with a destination inside the Hyprwave git
worktree packaging paths.

### Optional: install from lab into real user dir later

```bash
# Only after lab verify succeeded and you accept the password choice
mkdir -p ~/.duress
chmod 700 ~/.duress
cp -a "$LAB/10-clear-histories.sh" "$LAB/10-clear-histories.sh.sha256" ~/.duress/
# re-chmod after copy if umask interfered
chmod 500 ~/.duress/10-clear-histories.sh
chmod 400 ~/.duress/10-clear-histories.sh.sha256
hyprwave-duress-setup --verify
```

Prefer re-running `hyprwave-duress-setup --mild-template` over hand-copying when
possible so modes stay correct.

---

## Path C — Global (`/etc/duress.d`) — admin only

Global scripts run as **root** when a matching signed password authenticates.
Higher blast radius.

```bash
sudo hyprwave-duress-setup --system --dry-run --mild-template
# only after policy review:
# sudo hyprwave-duress-setup --system --mild-template
sudo hyprwave-duress-setup --verify /etc/duress.d
```

Stock images ship `/etc/duress.d` **empty** (README marker only).

---

## Modes cheat sheet

| Object | Required mode (upstream) |
|---|---|
| Script | `500`, `540`, or `550` |
| `.sha256` | typically `400` (setup enforces after sign) |
| User dir `~/.duress` | `700` recommended |
| Global dir `/etc/duress.d` | admin-controlled; empty on stock |

Wrong modes → pam_duress **ignores** the script.

---

## After signing: still no login change

Signing does **not** enable `pam_duress.so`. Until an admin follows
`ENABLE.md` / `OPERATOR-RUNBOOK.md` and inserts
`auth sufficient pam_duress.so` (after `pam_unix`), normal passwords never run
these scripts.

---

## Failure modes

| Symptom | Likely cause | Fix |
|---|---|---|
| `--verify` MISSING signature | Forgot `duress_sign` / aborted setup | Re-run setup or Path B |
| `--verify` bad mode | umask / manual copy | `chmod 500` script, `chmod 400` sig |
| `duress_sign: command not found` | Module not in image / PATH | Install packaging; check `BUILD-INFO.txt` |
| Login still never runs script | PAM still off (expected) | Human enable only after VM drill |
| Accidental `*.sha256` in git | Lab files under repo | Delete, never commit; re-run validate |

---

## CI / packaging checklist

```bash
bash planning/integration/d-duress/snippet-selftest.sh
bash planning/integration/d-duress/validate.sh
# Must stay: no *.sha256 under build_files/duress or planning/integration/d-duress
```
