# Enabling Hyprwave Duress (ADMIN / INTEGRATOR ONLY)

This file is the image-local copy of the enable procedure. The full copy is
`planning/integration/d-duress/ENABLE.md` (kept in sync for Wave 2).

**Default: OFF.** Packaging alone does not activate duress authentication.  
There is no supported `DURESS=enable` image build mode (assets only).

## Image layout (stock Hyprwave)

Inspected on `localhost/hyprwave:latest` (2026-08-13):

| Path | Stock state |
|---|---|
| `/usr/lib64/security/pam_duress.so` | Present (module ships) |
| `/usr/bin/hyprwave-duress-setup` | Present (opt-in tool) |
| `/usr/share/hyprwave/duress/` | README, ENABLE.md, `templates/`, `pam.d/` (docs only), BUILD-INFO |
| `/usr/share/hyprwave/duress/pam.d/*.snippet` | **Reference only** — not installed into `/etc/pam.d` |
| `/etc/duress.d/` | Exists; empty of scripts (README marker only) |
| `/etc/pam.d/*` | **Zero** `pam_duress` lines |
| `*.sha256` under duress paths | **None** |

Repo packaging also has `THREAT-MODEL.md` under `build_files/duress/` (may be
copied into `/usr/share/hyprwave/duress/` on later image rebuilds).

## Quick path (Fedora Atomic / ublue)

1. Keep a **root shell open** for the entire change + test window.

2. Backup PAM:

   ```bash
   sudo cp -a /etc/pam.d/system-auth "/etc/pam.d/system-auth.bak.$(date +%Y%m%d%H%M%S)"
   ```

3. After the `pam_unix` auth line in `/etc/pam.d/system-auth`, add:

   ```
   auth       sufficient                  pam_duress.so
   ```

4. Prefer **`sufficient`**, never start with `required`.

5. User opt-in (mild first):

   ```bash
   hyprwave-duress-setup --dry-run --mild-template
   hyprwave-duress-setup --mild-template
   hyprwave-duress-setup --status
   ```

6. Test **normal password** before any duress password.

## Login managers

| Component | Notes |
|---|---|
| SDDM | Often uses `system-auth` |
| cosmic-greeter / greetd | Check `/etc/pam.d/greetd` |
| hyprlock | Uses PAM; may inherit system-auth |

## Templates

| Severity | Template | Flag |
|---|---|---|
| MILD | `10-clear-histories.sh` | `--mild-template` |
| MILD | `20-local-only-clear.sh` | `--local-clear-template` |
| AGGRESSIVE | `00-wipe-sensitive.sh` | `--wipe-template` |

## Recovery if locked out

Mis-editing PAM (especially `required pam_duress.so` with a missing module) can
block all password logins. Prepare **before** the edit:

1. Keep `sudo -i` or a root TTY open for the whole window.
2. Take a timestamped backup of every file you touch.
3. Prefer `sufficient` so a missing module falls through to normal deny/unix paths.

### From an open root shell (preferred)

```bash
# List backups
ls -1 /etc/pam.d/system-auth.bak.* 2>/dev/null

# Restore the newest backup (replace TIMESTAMP)
sudo cp -a /etc/pam.d/system-auth.bak.TIMESTAMP /etc/pam.d/system-auth

# Or delete only the duress line
sudo sed -i '/pam_duress\.so/d' /etc/pam.d/system-auth

# Confirm
grep -n pam_duress /etc/pam.d/system-auth || echo "no pam_duress lines"
```

Then test **normal** password login from another session before closing root.

### If already locked out

1. Boot live USB / recovery image / single-user (lab policy dependent).
2. Mount the installed root (example device — **check yours**):

   ```bash
   mkdir -p /mnt/sysroot
   mount /dev/DISK /mnt/sysroot
   # bootc/ostree layouts may need the deploy root under /mnt/sysroot/...
   ```

3. Edit the PAM file under the mounted tree (same restore or `sed` as above).
4. Unmount, reboot, confirm normal login.
5. Re-run `hyprwave-duress-setup --status` and only re-enable after fixing the cause.

User scripts do not unlock PAM: removing `~/.duress/*` never fixes a broken stack.

## bootc upgrade PAM drift

Image updates can refresh vendor PAM files and **drop** your `pam_duress.so` line
(duress silently stops) or, rarely, conflict with a customized stack.

After every `bootc upgrade` (or rebase):

```bash
# Did the line survive?
grep -n 'pam_duress' /etc/pam.d/system-auth /etc/pam.d/sddm /etc/pam.d/greetd \
  /etc/pam.d/hyprlock 2>/dev/null || echo "no pam_duress references found"

# Module still present?
ls -l /usr/lib64/security/pam_duress.so

# Operator status
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
```

If the line vanished and you still want duress: re-apply `ENABLE.md` steps on a
**fresh backup**, re-test normal password first, then duress. Do not copy an old
backup blindly over a newer vendor stack without reading the diff:

```bash
diff -u /etc/pam.d/system-auth.bak.TIMESTAMP /etc/pam.d/system-auth || true
```

## Hard rules

- Prefer `sufficient`, not `required`, for `pam_duress.so`.
- Never ship pre-signed scripts or a shared default duress password.
- Fail-safe stock state: no PAM line + no signatures = normal auth only.
- Re-check PAM after `bootc upgrade` if vendor files refresh.
- Formal threat model: `THREAT-MODEL.md`. Operator drill: `planning/integration/d-duress/DRILL.md`.

Full test plan, rollback, Atomic notes: sibling `README.md` and
`planning/integration/d-duress/ENABLE.md`.
