# Integrator checklist — duress packaging freeze (assets only)

**Status:** packaging frozen for merge as **PAM OFF BY DEFAULT**.  
There is **no** supported path to enable `pam_duress` from Containerfile, CI, or
`build.sh` snippets. Enable is a **post-boot human** procedure only.

Use this list when merging Model D outputs into the live image tree.

Related: [README.md](./README.md) · [SIGNING.md](./SIGNING.md) · [RESIDUALS.md](./RESIDUALS.md) ·
[FAQ.md](./FAQ.md) · [OPERATOR-RUNBOOK.md](./OPERATOR-RUNBOOK.md) · [DRILL.md](./DRILL.md) ·
[ENABLE.md](./ENABLE.md) · [validate.sh](./validate.sh) · [snippet-selftest.sh](./snippet-selftest.sh)

---

## 0. Preconditions

- [ ] Review residual risks: **RESIDUALS.md** + image-local `THREAT-MODEL.md`
- [ ] Confirm product still wants **assets only** (no default PAM enable)
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

---

## 2. Apply snippets (wiring only)

1. Apply **`Containerfile.snippet`** → optional `duressbuilder` stage + `COPY --from=… /install/ /`
2. Apply **`build.sh.snippet`** → install templates, setup tool, empty `/etc/duress.d`, docs under `/usr/share/hyprwave/duress/`

- [ ] Snippets paste **as assets** — do not add `sed`/`cp` into `/etc/pam.d`
- [ ] Do **not** install `build_files/duress/pam.d/*.snippet` over live PAM files
- [ ] Do **not** introduce `DURESS=enable` or similar build-arg behavior

Re-check after paste:

```bash
bash planning/integration/d-duress/snippet-selftest.sh
```

---

## 3. Do **not** enable PAM in the merge

| Forbidden in merge PR | Correct path later |
|---|---|
| `auth … pam_duress.so` in any shipped `/etc/pam.d` | Human edits per **ENABLE.md** / **OPERATOR-RUNBOOK.md** |
| Baking `*.sha256` into the image | Operator **SIGNING.md** on the target host |
| Enabling PAM “just for CI” | Disposable VM **DRILL.md** only |

- [ ] Grep production `build.sh` / `Containerfile` after apply: no active `/etc/pam.d` duress writes
- [ ] Stock boot: normal password behavior unchanged

---

## 4. Run packaging gates (must stay green)

From repo root:

```bash
bash planning/integration/d-duress/snippet-selftest.sh
bash planning/integration/d-duress/validate.sh
```

- [ ] Both exit **0**
- [ ] `validate.sh` still reports no packaging-tree `*.sha256`
- [ ] Negative fixtures section still passes (proves policies catch bad trees)

Optional image smoke (after build, not required for lane freeze):

```bash
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
hyprwave-duress-setup --dry-run --mild-template
# expect: PAM off / empty or unsigned; dry-run only
```

---

## 5. Document operator ENABLE path only (do not run it in CI)

Point operators at docs **shipped or linked**, in this order:

1. **FAQ.md** — what it is / isn’t; off by default  
2. **RESIDUALS.md** — what packaging does not solve  
3. **SIGNING.md** — local sign + `--verify`; never commit signatures  
4. **DRILL.md** — disposable VM procedure  
5. **OPERATOR-RUNBOOK.md** — ordered enable → test → disable/rollback  
6. **ENABLE.md** — PAM insert (`sufficient` after `pam_unix`), recovery, bootc drift  

- [ ] Image or release notes mention: **default OFF**; enable is admin-only  
- [ ] No handbook claim that Hyprwave “ships with duress login enabled”

---

## 6. Build both variants (when integrating live)

- [ ] Hyprland variant builds with duress stage if wired  
- [ ] COSMIC variant: same assets policy (still no PAM enable)  
- [ ] Confirm runtime paths when present:
  - `/usr/lib64/security/pam_duress.so`
  - `/usr/bin/duress_sign`
  - `/usr/bin/hyprwave-duress-setup`
  - `/usr/share/hyprwave/duress/templates/`
  - `/etc/duress.d/` empty (marker README only)

---

## 7. Freeze sign-off

| Check | Pass? |
|---|---|
| Packaging OFF by default | |
| Zero `*.sha256` in git / packaging tree | |
| Snippets PAM-inert (`snippet-selftest`) | |
| `validate.sh` PASSED | |
| No accidental enable path in build hooks | |
| Operator ENABLE docs linked from integration README | |

**Merge intent:** `DURESS=assets` only.  
**Post-merge enable:** human + disposable VM first — never automatic.

---

## Quick command card

```bash
# Lane / packaging freeze
bash planning/integration/d-duress/snippet-selftest.sh
bash planning/integration/d-duress/validate.sh
find build_files/duress planning/integration/d-duress -name '*.sha256'   # empty

# After image install (still must not auto-enable)
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
```
