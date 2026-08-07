# Enabling Hyprwave Duress (ADMIN / INTEGRATOR ONLY)

**Default: OFF.** Applying packaging snippets alone does **not** activate duress
authentication. Follow this document only after:

1. You understand the threat model in `/usr/share/hyprwave/duress/README.md`
2. You have tested in a **disposable VM** (not your daily driver first)
3. You accept that mis-editing PAM can lock everyone out of the machine

There is **no** supported Containerfile/CI mode `DURESS=enable`.  
Build intent is always **assets only** (`DURESS=assets` as documentation).

## Prerequisites

- Image contains:
  - `/usr/lib64/security/pam_duress.so`
  - `/usr/bin/duress_sign`
  - `/usr/bin/hyprwave-duress-setup`
  - templates under `/usr/share/hyprwave/duress/templates/`
- Root / admin access to edit `/etc/pam.d/`
- A second root session you can use if login breaks

Optional before PAM enable: sign a **mild** script so you can test without
destroying keys:

```bash
hyprwave-duress-setup --dry-run --mild-template
hyprwave-duress-setup --mild-template
```

## Fedora Atomic / bootc notes

- `/etc` is writable; PAM edits survive until the next intentional reset of that file.
- Image updates via `bootc upgrade` may **replace** vendor PAM files if they are
  owned by packages — re-check `system-auth` after upgrades (commands below).
- Prefer a small drop-in mindset: one `sufficient pam_duress.so` line, not a full
  stack rewrite.
- Keep recovery media or a root console path ready (serial, second account, live USB).

### Post-upgrade PAM drift check (example commands)

```bash
# After: sudo bootc upgrade && sudo systemctl reboot
grep -n 'pam_duress' /etc/pam.d/system-auth /etc/pam.d/sddm /etc/pam.d/greetd \
  /etc/pam.d/hyprlock 2>/dev/null || echo "no pam_duress references found"

ls -l /usr/lib64/security/pam_duress.so
hyprwave-duress-setup --status
hyprwave-duress-setup --verify

# If the enable line vanished, re-apply after backup — do not blind-restore an
# ancient system-auth over a newer vendor file without reading the diff:
#   diff -u /etc/pam.d/system-auth.bak.TIMESTAMP /etc/pam.d/system-auth
```

## Keep a root shell open (mandatory checklist)

Before editing PAM on a real machine or long-lived VM:

- [ ] `sudo -i` (or root on TTY2) left open for the whole test
- [ ] Backup taken (step below)
- [ ] You know how to restore the backup from that root shell
- [ ] Normal password login tested **before** any duress password test
- [ ] You will test greeter **and** hyprlock if both matter to you

## Recommended enable path (Fedora / ublue): `system-auth`

Most greeters and locks eventually hit `system-auth`. One careful edit may cover:

- SDDM (Hyprland)
- greetd / cosmic-greeter (when it includes system-auth)
- hyprlock (when it includes system-auth)
- `sudo`, `login`, etc. — **be aware of blast radius**

### Steps

1. **Backup**

   ```bash
   sudo cp -a /etc/pam.d/system-auth "/etc/pam.d/system-auth.bak.$(date +%Y%m%d%H%M%S)"
   ```

2. **Inspect** the current `auth` block:

   ```bash
   grep -n '^auth' /etc/pam.d/system-auth
   ```

3. **Insert** a single line **immediately after** the successful `pam_unix` auth
   line, using **`sufficient`** (not `required`):

   ```
   auth       sufficient                  pam_duress.so
   ```

   Example transform:

   ```
   auth       sufficient                  pam_unix.so nullok
   auth       sufficient                  pam_duress.so
   auth       required                    pam_deny.so
   ```

   On stacks that use jump syntax (`[success=N default=ignore]`), follow the
   upstream pam-duress README and adjust jump counts so:

   - unix success skips duress **and** deny
   - duress success skips deny
   - failure falls through to deny

4. **Verify module present**

   ```bash
   ls -l /usr/lib64/security/pam_duress.so
   hyprwave-duress-setup --status
   hyprwave-duress-setup --status --json
   ```

5. **Test normal password first** (must still work) from greeter and/or `login`.

## Greeter-specific notes

### SDDM (Hyprland)

- File: `/etc/pam.d/sddm`
- Often includes `system-auth` — system-auth enable may be enough.
- **Do not** overwrite the whole file with reference snippets without merging
  account/session lines.

### greetd / cosmic-greeter (COSMIC)

```bash
ls /etc/pam.d/greetd /etc/pam.d/cosmic-greeter 2>/dev/null
cat /etc/pam.d/greetd 2>/dev/null
```

Same rule: after `pam_unix`, add `sufficient pam_duress.so` **or** rely on
system-auth if included. Re-test COSMIC login after any PAM change.

### hyprlock

```bash
cat /etc/pam.d/hyprlock 2>/dev/null || echo "no dedicated hyprlock pam file"
```

If hyprlock uses system-auth, unlock inherits duress. Test normal unlock before
duress unlock.

## User configuration

```bash
# Mild (recommended for first test)
hyprwave-duress-setup --mild-template

# Mild: local browser session caches under ~/.cache only
hyprwave-duress-setup --local-clear-template

# Aggressive wipe (keys/browsers/secrets)
hyprwave-duress-setup --wipe-template

# Status / read-only integrity
hyprwave-duress-setup --status
hyprwave-duress-setup --verify
hyprwave-duress-setup --list
```

Global (root):

```bash
sudo hyprwave-duress-setup --system --mild-template
```

Rules from upstream:

- Scripts: `~/.duress/` (user) or `/etc/duress.d/` (global)
- Mode must be `500`, `540`, or `550`
- Matching `script.sha256` from `duress_sign`
- Env: `PAMUSER`

## Test plan (disposable VM)

| # | Action | Expected |
|---|---|---|
| 1 | Login with **normal** password, no signed scripts | Success, no side effects |
| 2 | `--dry-run --mild-template` | Preview only; no `.sha256` |
| 3 | Sign mild template | `.sha256` created; mode 500 |
| 4 | Login / unlock with **normal** password | Success; data **intact** |
| 5 | Login / unlock with **duress** password | Success; mild clears run; no error UI |
| 6 | Optional: aggressive template on a throwaway account | Secrets wiped |
| 7 | Wrong password | Fail as usual |
| 8 | COSMIC greeter if shipping both variants | Same as 4–5 |
| 9 | Image build / `bootc container lint` | No packaging regression |

## Disable / rollback

From the **open root shell**:

```bash
sudo cp /etc/pam.d/system-auth.bak.TIMESTAMP /etc/pam.d/system-auth
# or remove only the pam_duress.so line
sudo sed -i '/pam_duress\.so/d' /etc/pam.d/system-auth
grep -n pam_duress /etc/pam.d/system-auth || echo "no pam_duress lines"
```

```bash
hyprwave-duress-setup --list
hyprwave-duress-setup --verify
hyprwave-duress-setup --remove 10-clear-histories.sh
hyprwave-duress-setup --remove 20-local-only-clear.sh
hyprwave-duress-setup --remove 00-wipe-sensitive.sh
```

## Recovery if locked out

1. **Preferred:** use the still-open root shell to restore `*.bak.*` or delete
   `pam_duress.so` lines (commands above). Test normal password before logout.
2. **Already locked out:** boot live/recovery, mount the install root, edit the
   same PAM files under the mount, reboot. Removing `~/.duress` never fixes PAM.
3. Avoid `required pam_duress.so` unless you have tested missing-module behavior;
   `sufficient` is the supported first enable.

Full disposable-VM timing: `planning/integration/d-duress/DRILL.md`.

## Hard no’s

- Do **not** enable by default in CI or release images.
- Do **not** ship pre-signed scripts or shared default duress passwords.
- Do **not** use `required` for `pam_duress.so` unless you have tested missing-module behavior.
- Do **not** rely on duress as the only protection for high-value data.

## Integrator checklist

- [ ] `build-duress.sh` wired in Containerfile builder stage
- [ ] `build.sh.snippet` applied (templates + setup tool + empty `/etc/duress.d`)
- [ ] `ENABLE.md` installed under `/usr/share/hyprwave/duress/ENABLE.md`
- [ ] **No** unconditional PAM edits in build.sh
- [ ] `planning/integration/d-duress/validate.sh` passes in CI or pre-merge
- [ ] VM test matrix above executed before documenting “supported”
