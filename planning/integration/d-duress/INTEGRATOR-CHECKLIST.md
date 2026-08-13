# Integrator checklist — duress packaging freeze (assets only)

**Status:** packaging frozen for merge as **PAM OFF BY DEFAULT** / **never default-on**.  
There is **no** supported path to enable `pam_duress` from Containerfile, CI, or
`build.sh` snippets. Enable is a **post-boot human** procedure only.

**Wave coverage (merge-prep through W4):**

| Wave | What landed (still OFF) |
|---|---|
| W1 | Assets, templates, setup tool, threat model, freeze docs |
| W2 | Image path layout + ENABLE residual; **DRILL.md** PAM-inert rehearsal |
| W3 | Negative fixtures: pam **snippets** must not install into `/etc/pam.d` |
| W4 | This checklist refresh + green `validate.sh` / duress-safety |

Use this list when merging Model D outputs into the live image tree.

Related: [README.md](./README.md) · [SIGNING.md](./SIGNING.md) · [RESIDUALS.md](./RESIDUALS.md) ·
[FAQ.md](./FAQ.md) · [OPERATOR-RUNBOOK.md](./OPERATOR-RUNBOOK.md) · [DRILL.md](./DRILL.md) ·
[ENABLE.md](./ENABLE.md) · [validate.sh](./validate.sh) · [snippet-selftest.sh](./snippet-selftest.sh) ·
[INTEGRATION-DAY.md](./INTEGRATION-DAY.md)

---

## 0. Preconditions

- [ ] Review residual risks: **RESIDUALS.md** (still **OFF** residual) + image-local `THREAT-MODEL.md`
- [ ] Confirm product still wants **assets only** (no default PAM enable — **never default-on**)
- [ ] Work from a clean tree; no accidental `*.sha256` under packaging paths

```bash
find build_files/duress planning/integration/d-duress -type f -name '*.sha256'
# expect: no output
```

---

## 1. Merge packaging tree (lane → main integration PR)

Copy or merge **only** these sources of truth (do not invent enable flags):

| Source | Role |
|---|---|
| `build_files/build-duress.sh` | Builder pin + stage to `$DESTROOT` |
| `build_files/duress/**` | Templates, setup tool, docs, reference pam.d snippets |
| `planning/integration/d-duress/*` | Snippets + operator docs + validate |

- [ ] No edits to skel, assistant, or product handbook in this change
- [ ] No pre-signed scripts; templates remain **unsigned**
- [ ] Pin still full 40-char SHA; builder prints `pin=` + `date=`
- [ ] Model D lane does **not** edit live `build_files/build.sh` for product work
      (read-only audit via validate / snippet-selftest after someone else wires snippets)

---

## 2. Apply snippets (wiring only)

1. Apply **`Containerfile.snippet`** → optional `duressbuilder` stage + `COPY --from=… /install/ /`
2. Apply **`build.sh.snippet`** → install templates, setup tool, empty `/etc/duress.d`, docs under `/usr/share/hyprwave/duress/`

- [ ] Snippets paste **as assets** — do not add `sed`/`cp` into `/etc/pam.d`
- [ ] Do **not** install `build_files/duress/pam.d/*.snippet` over live PAM files
- [ ] Do **not** `cp -a …/pam.d/. /etc/pam.d/` or `install … /etc/pam.d/*` (W3 N7 gate)
- [ ] Do **not** introduce `DURESS=enable` or similar build-arg behavior

Re-check after paste:

```bash
bash planning/integration/d-duress/snippet-selftest.sh
```

---

## 3. Do **not** enable PAM in the merge (**never default-on**)

| Forbidden in merge PR | Correct path later |
|---|---|
| `auth … pam_duress.so` in any shipped `/etc/pam.d` | Human edits per **ENABLE.md** / **OPERATOR-RUNBOOK.md** |
| Copying reference `pam.d/*.snippet` onto live stacks | Leave snippets under `/usr/share/hyprwave/duress/pam.d/` only |
| Baking `*.sha256` into the image | Operator **SIGNING.md** on the target host |
| Enabling PAM “just for CI” | Disposable VM **DRILL.md** (rehearsal) then runbook enable — never CI |

- [ ] Grep production `build.sh` / `Containerfile` after apply: no active `/etc/pam.d` duress writes
- [ ] `active_pam_snippet_to_etc` policy green (validate N7 + snippet-selftest negatives)
- [ ] Stock boot: normal password behavior unchanged

---

## 4. Run packaging gates (must stay green)

From repo root:

```bash
bash planning/integration/d-duress/snippet-selftest.sh
bash planning/integration/d-duress/validate.sh
bash planning/qa/run-all.sh --only duress-safety
```

- [ ] All three exit **0** / RESULT OK
- [ ] `validate.sh` still reports no packaging-tree `*.sha256`
- [ ] Negative fixtures still pass, including:
  - planted `*.sha256`
  - active `auth required pam_duress`
  - generic build-hook write into `/etc/pam.d`
  - **W3:** `cp` pam.d snippets → `/etc/pam.d` and `install` snippet over `system-auth`
  - **W3:** share-only `/usr/share/hyprwave/duress/pam.d` deploy is **allowed**

Optional image smoke (after build, not required for lane freeze):

```bash
# Stock image paths (W2) — still OFF
test -x /usr/bin/hyprwave-duress-setup
ls -l /usr/lib64/security/pam_duress.so
ls -la /usr/share/hyprwave/duress/templates/
ls -la /etc/duress.d/   # README only
hyprwave-duress-setup --help
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
hyprwave-duress-setup --dry-run --mild-template
grep -RIn pam_duress /etc/pam.d 2>/dev/null || echo "OK: zero pam_duress"
# expect: PAM off / empty or unsigned; dry-run only; no /etc/pam.d lines
```

---

## 5. Document operator ENABLE path only (do not run it in CI)

Point operators at docs **shipped or linked**, in this order:

1. **FAQ.md** — what it is / isn’t; off by default  
2. **RESIDUALS.md** — what packaging does not solve (**still OFF**)  
3. **SIGNING.md** — local sign + `--verify`; never commit signatures  
4. **DRILL.md** — **PAM-inert** path rehearsal (`--help` / `--status` / `--verify` / `--dry-run`); not production enable  
5. **OPERATOR-RUNBOOK.md** — ordered enable → test → disable/rollback (starts **after** drill)  
6. **ENABLE.md** — PAM insert (`sufficient` after `pam_unix`), recovery, bootc drift  

- [ ] Image or release notes mention: **default OFF** / **never default-on**; enable is admin-only  
- [ ] No handbook claim that Hyprwave “ships with duress login enabled”  
- [ ] DRILL is not mistaken for an enable runbook (enable stays §3+ of OPERATOR-RUNBOOK)

---

## 6. Build both variants (when integrating live)

- [ ] Hyprland variant builds with duress stage if wired  
- [ ] COSMIC variant: same assets policy (still no PAM enable)  
- [ ] Confirm runtime paths when present:
  - `/usr/lib64/security/pam_duress.so`
  - `/usr/bin/duress_sign`
  - `/usr/bin/hyprwave-duress-setup` (install path; not `/usr/sbin`)
  - `/usr/share/hyprwave/duress/templates/`
  - `/usr/share/hyprwave/duress/pam.d/*.snippet` (docs only)
  - `/etc/duress.d/` empty of scripts (marker README only)
  - **Zero** `pam_duress` lines under `/etc/pam.d`

---

## 7. Freeze sign-off (Wave 4 merge-prep)

| Check | Pass? |
|---|---|
| Packaging **OFF by default** / **never default-on** | |
| Zero `*.sha256` in git / packaging tree | |
| Snippets PAM-inert (`snippet-selftest`) | |
| `validate.sh` PASSED (incl. W3 pam-snippet N7) | |
| `duress-safety` harness PASSED | |
| No accidental enable path in build hooks | |
| DRILL documents real image paths; rehearsal only | |
| RESIDUALS still **OFF** residual present | |
| Operator ENABLE docs linked from integration README | |

**Merge intent:** `DURESS=assets` only.  
**Post-merge enable:** human + disposable VM first — **never** automatic, **never** CI default-on.

---

## Quick command card

```bash
# Lane / packaging freeze
bash planning/integration/d-duress/snippet-selftest.sh
bash planning/integration/d-duress/validate.sh
bash planning/qa/run-all.sh --only duress-safety
find build_files/duress planning/integration/d-duress -name '*.sha256'   # empty

# After image install (still must not auto-enable)
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
# Full path inventory: planning/integration/d-duress/DRILL.md Phases B–C
```
