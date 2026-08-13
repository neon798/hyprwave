# Residual operator duties (what packaging does **not** solve)

**Audience:** integrators, Model B docs handoff, security reviewers.  
**Packaging status:** assets only; **PAM OFF BY DEFAULT**; no pre-signed scripts.

Hyprwave duress packaging raises the cost of **live coercion** when a human
opts in. It does **not** close the residual risks below. Operators still own them.

Full technical model: `build_files/duress/THREAT-MODEL.md`.  
Operator how-to: `FAQ.md` · `OPERATOR-RUNBOOK.md` · `SIGNING.md` · `ENABLE.md`.

---

## 1. Disk encryption (LUKS / volume crypto)

| Packaging provides | Operator still owns |
|---|---|
| Optional scripts that clear *selected* paths after a successful auth path | Full-disk / volume encryption at rest |
| Docs stating LUKS is a non-goal | Passphrase hygiene, unlock policy, recovery keys |

**Residual:** A seized disk, cold image, or offline forensic copy can retain data
duress never touched (or only partially cleared). Duress is **not** a substitute
for LUKS or similar.

---

## 2. Physical access / evil maid / root

| Packaging provides | Operator still owns |
|---|---|
| No automatic phone-home; no default PAM rewrite | Physical security, secure boot policy, firmware trust |
| Staging binaries only in builder → image | Detection of evil-maid, supply-chain, or pre-enabled PAM |

**Residual:** Anyone with root or physical write access can disable duress,
re-sign scripts, install keyloggers, or image the disk before coercion.

---

## 3. Signed-script trust root

| Packaging provides | Operator still owns |
|---|---|
| Unsigned templates only in git/image | Choice of duress password (distinct from login) |
| `hyprwave-duress-setup` + `duress_sign` workflow (`SIGNING.md`) | Review of every script before sign |
| `validate.sh` forbids packaging-tree `*.sha256` | Not reusing lab signatures on production hosts |
| `--verify` for modes + name pairing | Crypto trust: only you know the duress password |

**Residual:** A signed aggressive script **will** destroy what it targets when
the duress password is used. Wrong template, wrong scope, or a compromised
`duress_sign` session is operator error / host compromise — packaging cannot
review intent.

---

## 4. bootc / package PAM drift

| Packaging provides | Operator still owns |
|---|---|
| Docs + runbook post-upgrade checks | Re-checking `/etc/pam.d/*` after every `bootc upgrade` |
| Recovery language in `ENABLE.md` | Re-applying enable lines carefully after vendor stack changes |
| Prefer `sufficient` over `required` | Keeping a recovery path (root shell, live USB) |

**Residual:** Image updates may **silently drop** a hand-edited `pam_duress`
line (duress stops) or refresh vendor stacks in ways that conflict with an old
backup. Blind restore of ancient `system-auth` over a newer vendor file is unsafe.

---

## 5. Incomplete wipe / residual data

| Packaging provides | Operator still owns |
|---|---|
| Graded templates (mild histories, local cache, aggressive common paths) | Secrets stored outside template TARGETS |
| Severity labels in README | Custom secret locations, cloud sync copies, external drives |
| Explicit non-goal: forensic-grade erase | Understanding SSD/journal/snapshot limits |

**Residual:** Best-effort `rm`/`shred` leaves forensic residue. Snapshots,
backups, and prior disk images keep old secrets.

---

## 6. Social and operational failure

| Packaging provides | Operator still owns |
|---|---|
| Silent success design (no “duress mode” UI) | User training under stress |
| Disposable VM drill (`DRILL.md`) | Not enabling on multi-user shared machines without policy |
| Lockout recovery docs | Not using `required pam_duress` as first enable |

**Residual:** Users may type the wrong password class, reveal both secrets, or
enable on a machine where lockout costs everyone access.

---

## 7. Integration boundary (Model D lane)

| This lane delivers | Outside this lane |
|---|---|
| Snippets, templates, setup tool, validate, operator docs | Live `Containerfile` / `build.sh` merge (integrator) |
| Proof packaging is inert (`snippet-selftest.sh`, `validate.sh`) | Product handbook prose (Model B) |
| Explicit “no DURESS=enable” | Product decision to ever enable PAM by default (forbidden here) |

**Residual for integrators:** Applying snippets without re-running `validate.sh`,
or enabling PAM in the same PR as first packaging land, reintroduces lockout risk.

---

## One-page operator checklist

- [ ] `bash planning/integration/d-duress/validate.sh` green before merge  
- [ ] `bash planning/integration/d-duress/snippet-selftest.sh` green  
- [ ] No `*.sha256` in image or git  
- [ ] LUKS (or equivalent) still on for at-rest protection  
- [ ] Sign only after `--dry-run` + disposable VM (`SIGNING.md`, `DRILL.md`)  
- [ ] PAM enable only with open root shell + backup (`OPERATOR-RUNBOOK.md`)  
- [ ] Post-`bootc upgrade` PAM drift check  
- [ ] Accept residual risks above in writing for your deployment policy  

**Packaging endpoint:** shipped **OFF by default**. Residual confidence is
operational, not a crypto guarantee.

---

## Still OFF — image residual (Wave 2 / D-W2-001)

Image inspect of `localhost/hyprwave:latest` (2026-08-13) confirmed:

| Fact | Residual meaning |
|---|---|
| `pam_duress.so` present under `/usr/lib64/security/` | Presence ≠ enablement |
| `hyprwave-duress-setup` present | Operator tooling only |
| **Zero** `pam_duress` lines under `/etc/pam.d` | Stock auth unchanged |
| `/etc/duress.d` has README only (no scripts / no `.sha256`) | Nothing runs on login |
| Reference snippets only under `/usr/share/hyprwave/duress/pam.d/` | Not live PAM stacks |

**Still OFF residual:** Future builds must keep this invariant. `validate.sh` +
`snippet-selftest.sh` + `planning/qa/check-duress-safety.sh` gate packaging
regressions; they do not replace a post-build image inspect of `/etc/pam.d`.
