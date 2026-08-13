# Hyprwave duress — operator FAQ

**Audience:** integrators and admins evaluating or enabling duress packaging.  
**Default:** **OFF.** Stock images do not enable `pam_duress` and ship no signed scripts.

---

### 1. What is duress packaging?

A build-time and image packaging layer for [nuvious/pam-duress](https://github.com/nuvious/pam-duress): binaries (`pam_duress.so`, `duress_sign`, `pam_test`), unsigned action templates, `hyprwave-duress-setup`, and docs. At runtime a **duress password** can authenticate like a normal password while running signed scripts in the background.

### 2. What is it *not*?

- Not full-disk encryption or a LUKS substitute  
- Not forensic-grade wipe (SSD wear-leveling, snapshots, prior images remain)  
- Not a “duress mode” UI or second visible desktop profile  
- Not a product guarantee against prepared attackers who already know duress exists  
- Not an automatic CI/image feature that rewrites PAM  

See `build_files/duress/THREAT-MODEL.md` for assets, adversaries, residual risks, and non-goals.

### 3. Is pam_duress enabled by default?

**No.** Packaging is **assets only**. Build hooks stage files under `/usr` and create an empty `/etc/duress.d`. They must never write `/etc/pam.d/*`. Login behavior is unchanged until a human follows `ENABLE.md` / `OPERATOR-RUNBOOK.md`.

### 4. What does “off by default” mean in practice?

| Condition | Behavior |
|---|---|
| Module present, no PAM line | Zero change |
| PAM line present, no signed scripts | Module ignores; normal passwords still work |
| Signed scripts, no PAM line | Scripts never run at login |
| Both PAM + signed scripts | Duress password can run scripts |

### 5. How do signing scripts work?

1. Copy a template with `hyprwave-duress-setup` (or manually into `~/.duress/` / `/etc/duress.d/`).  
2. `duress_sign` prompts for the **duress** password and writes a matching `*.sha256`.  
3. Upstream requires script modes `500`, `540`, or `550` and signature mode typically `400`.  
4. **Never** commit or bake `*.sha256` into the image or git tree.

Preview without signing:

```bash
hyprwave-duress-setup --dry-run --mild-template
hyprwave-duress-setup --dry-run --local-clear-template
```

### 6. How do greeter and hyprlock relate?

Most greeters (SDDM, greetd/cosmic-greeter) and hyprlock eventually hit a PAM service file. On Fedora/ublue, enabling once in **`system-auth`** with `auth sufficient pam_duress.so` after `pam_unix` often covers greeter **and** lock — but **inspect the actual stack** (`/etc/pam.d/sddm`, `greetd`, `hyprlock`). Reference-only fragments live under `build_files/duress/pam.d/*.snippet`. Always test greeter **and** lock if both matter to you.

### 7. What if I get locked out?

Mis-editing PAM (especially `required pam_duress.so` with a missing module) can block password logins.

1. Prefer keeping a **root shell open** for the entire enable window.  
2. Restore a timestamped backup of the PAM file you edited.  
3. Or `sed -i '/pam_duress\.so/d' …` the line.  
4. If already locked out: live USB / recovery mount, edit the deployed PAM file, reboot.  

Removing `~/.duress/*` **never** fixes a broken PAM stack. Details: `ENABLE.md` recovery section and `OPERATOR-RUNBOOK.md`.

### 8. What happens on `bootc upgrade` / image rebase?

Vendor PAM files may be refreshed. Your `pam_duress.so` line can **disappear** (duress silently stops) or rarely conflict. After every upgrade:

```bash
grep -n 'pam_duress' /etc/pam.d/system-auth /etc/pam.d/sddm /etc/pam.d/greetd \
  /etc/pam.d/hyprlock 2>/dev/null || echo "no pam_duress references found"
ls -l /usr/lib64/security/pam_duress.so
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
```

Re-apply enable steps on a **fresh backup** after reading diffs — do not blind-restore an ancient `system-auth` over a newer vendor stack.

### 9. Residual risk vs LUKS — what should I still use?

| Control | Role |
|---|---|
| **LUKS / volume crypto** | Protects data at rest when the machine is off or disk is seized offline |
| **Duress (opt-in)** | Raises cost of *live coercion* at password entry; may clear selected paths under `$HOME` |
| **Good operational hygiene** | Separate secrets, backups, minimal signed scripts |

Duress does **not** replace disk encryption. A forensic examiner with a disk image can still recover residual data. Documented residual risks: incomplete wipe, PAM lockout, bootc drift, side channels, social pressure (`THREAT-MODEL.md`).

### 10. Which template should I start with?

| Severity | Template | Flag |
|---|---|---|
| **MILD** (start here) | `10-clear-histories.sh` | `--mild-template` |
| **MILD** | `20-local-only-clear.sh` | `--local-clear-template` |
| **AGGRESSIVE** | `00-wipe-sensitive.sh` | `--wipe-template` |

Always `--dry-run` first. Test in a **disposable VM** (`DRILL.md`) before any daily driver.

### 11. How do I prove packaging is still PAM-off / safe in-repo?

```bash
bash planning/integration/d-duress/validate.sh
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
hyprwave-duress-setup --dry-run --mild-template
```

`validate.sh` fails if packaging trees contain `*.sha256`, if build snippets actively write `/etc/pam.d`, if required `pam_duress` is prescribed as a default, or if threat-model / enable docs regress. Negative fixtures inside `validate.sh` re-assert those failure modes on temp dirs.

### 12. Can CI or the Containerfile enable PAM for me?

**No supported path.** There is no `DURESS=enable` image mode. Snippets document `DURESS=assets` only. Enabling is a post-boot human decision after VM testing. Model D lane policy forbids enabling PAM by default in the shipped image.

### 13. Where are the ordered enable / disable steps?

See **`OPERATOR-RUNBOOK.md`** (enable → disposable VM test → disable/rollback) and **`DRILL.md`** (timed 30–45 min procedure). Full enable prose: `ENABLE.md` (repo + image copy under `/usr/share/hyprwave/duress/`).
