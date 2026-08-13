# Operator runbook — enable, test, disable / rollback

Ordered steps for Hyprwave duress packaging. **PAM stays OFF** until you complete
the enable section deliberately. Prefer a disposable VM first (`DRILL.md`).

Related docs: `ENABLE.md` · `FAQ.md` · `DRILL.md` · `THREAT-MODEL.md` · `validate.sh`

---

## 0. Preconditions (always)

- [ ] Repo packaging green: `bash planning/integration/d-duress/validate.sh` → `RESULT: PASSED`
- [ ] Image (or bind-mount) has: `pam_duress.so`, `duress_sign`, `hyprwave-duress-setup`, templates
- [ ] You can keep a **root shell open** for the whole window (`sudo -i` or root TTY)
- [ ] Recovery path known (backup restore commands, or live USB)
- [ ] Not your only daily driver for first enable

---

## 1. Stock image proof (PAM must stay off)

Do this on every build you care about before enable:

```bash
# Repo host
bash planning/integration/d-duress/validate.sh

# In VM / installed system
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
grep -n pam_duress /etc/pam.d/* 2>/dev/null || echo "OK: no pam_duress lines"
ls -l /usr/lib64/security/pam_duress.so
test -z "$(find /etc/duress.d -name '*.sha256' 2>/dev/null)" && echo "OK: no system signatures"
```

**Pass:** status shows PAM off / no enable lines; verify OK; normal password login unchanged.

If validate fails, **stop**. Do not enable PAM on a broken tree.

---

## 2. Sign a mild script (still no PAM)

```bash
hyprwave-duress-setup --dry-run --mild-template
hyprwave-duress-setup --mild-template
hyprwave-duress-setup --verify
hyprwave-duress-setup --status
```

Optional local-only cache clear template:

```bash
hyprwave-duress-setup --dry-run --local-clear-template
# hyprwave-duress-setup --local-clear-template   # only after dry-run review
```

**Pass:** mode `500` script + matching `.sha256`; normal password still does **not** run scripts (PAM off).

---

## 3. Enable PAM (human only)

Keep root open. Prefer **`sufficient`**, never start with **`required`**.

```bash
# Backup
sudo cp -a /etc/pam.d/system-auth "/etc/pam.d/system-auth.bak.$(date +%Y%m%d%H%M%S)"

# Inspect
grep -n '^auth' /etc/pam.d/system-auth

# Edit: insert AFTER pam_unix success line:
#   auth       sufficient                  pam_duress.so
# Use your editor; do not replace the whole vendor file blindly.
```

Confirm:

```bash
grep -n pam_duress /etc/pam.d/system-auth
hyprwave-duress-setup --status
```

If greeter or hyprlock use a separate service file that does **not** include
`system-auth`, apply the same **surgical** insert there after backup (see
`build_files/duress/pam.d/*.snippet` — reference only).

---

## 4. Test in disposable VM (order matters)

| Order | Test | Expected |
|---|---|---|
| 1 | **Normal** password (greeter) | Login OK; mild script **does not** run |
| 2 | **Normal** password (hyprlock if used) | Unlock OK; no unwanted clear |
| 3 | **Duress** password | Session OK; mild clear runs; no “duress mode” UI |
| 4 | Wrong password | Fail as usual |

If step 1 fails: **immediately** jump to §5 rollback from the open root shell.

Full timed procedure: **`DRILL.md`** (Phases A–D, 30–45 minutes).

---

## 5. Disable / rollback (ordered)

### 5a. Soft disable (keep module & user scripts)

From open root:

```bash
# Remove only the duress auth line(s)
sudo sed -i '/pam_duress\.so/d' /etc/pam.d/system-auth
# Repeat for any other files you edited (sddm, greetd, hyprlock)

grep -n pam_duress /etc/pam.d/* 2>/dev/null || echo "pam_duress lines cleared"
```

Test **normal** password login before closing root.

### 5b. Full restore from backup (preferred after a bad edit)

```bash
ls -1 /etc/pam.d/system-auth.bak.*
sudo cp -a /etc/pam.d/system-auth.bak.TIMESTAMP /etc/pam.d/system-auth
grep -n pam_duress /etc/pam.d/system-auth || echo "restored clean of pam_duress"
```

### 5c. User scripts only (does **not** fix PAM)

```bash
# Optional: remove signed user scripts
rm -f ~/.duress/* ~/.duress/*.sha256 2>/dev/null
hyprwave-duress-setup --verify
```

### 5d. Locked out with no root shell

1. Boot live USB / recovery.  
2. Mount installed root (device path is site-specific; bootc may nest under a deploy dir).  
3. Restore backup or `sed` out `pam_duress` under the mounted `/etc/pam.d`.  
4. Unmount, reboot, confirm normal login.  
5. Only re-enable after root-causing the failure.

---

## 6. Post-upgrade re-check (bootc)

After `bootc upgrade` / rebase / reboot:

```bash
grep -n 'pam_duress' /etc/pam.d/system-auth /etc/pam.d/sddm /etc/pam.d/greetd \
  /etc/pam.d/hyprlock 2>/dev/null || echo "no pam_duress references found"
ls -l /usr/lib64/security/pam_duress.so
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
```

If the line vanished and you still want duress: re-run §3 on a **new** backup after
`diff` against the vendor file. Do not overlay an ancient backup blindly.

---

## 7. Decision summary

| Goal | Action |
|---|---|
| Ship assets only | Integrate snippets; never touch PAM in build |
| Evaluate safely | `validate.sh` + `DRILL.md` in disposable VM |
| Enable | §2 mild sign → §3 `sufficient` → §4 ordered tests |
| Disable | §5a or §5b; confirm normal login |
| After upgrade | §6 drift check |

**Never** enable PAM in Containerfile/CI as default. **Never** bake `*.sha256` into the image.
