# Enabling Hyprwave Duress (ADMIN / INTEGRATOR ONLY)

**Default: OFF.** Applying packaging snippets alone does **not** activate duress
authentication. Follow this document only after:

1. You understand the threat model in `/usr/share/hyprwave/duress/README.md`
2. You have tested in a **disposable VM**
3. You accept that mis-editing PAM can lock everyone out of the machine

## Prerequisites

- Image contains:
  - `/usr/lib64/security/pam_duress.so`
  - `/usr/bin/duress_sign`
  - `/usr/bin/hyprwave-duress-setup`
  - templates under `/usr/share/hyprwave/duress/templates/`
- At least one **signed** script (user `~/.duress/` or `/etc/duress.d/`)
- Root / admin access to edit `/etc/pam.d/`

## Recommended enable path (Fedora / ublue): `system-auth`

Most greeters and locks eventually hit `system-auth`. One careful edit covers:

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

4. **Keep a root shell open** in another TTY/SSH session while testing.

5. **Verify module load** (optional):

   ```bash
   ls -l /usr/lib64/security/pam_duress.so
   hyprwave-duress-setup --status
   ```

## Greeter-specific notes

### SDDM (Hyprland)

- File: `/etc/pam.d/sddm`
- Often `@include` / `substack` to `system-auth` — enabling system-auth may be enough.
- If sddm has a fully inlined stack, insert `pam_duress` there instead (see
  `build_files/duress/pam.d/sddm.snippet`).
- **Do not** overwrite the whole file with the reference snippet without merging
  account/session lines.

### greetd / cosmic-greeter (COSMIC)

- Check:

  ```bash
  ls /etc/pam.d/greetd /etc/pam.d/cosmic-greeter 2>/dev/null
  cat /etc/pam.d/greetd 2>/dev/null
  ```

- Same rule: after `pam_unix`, add `sufficient pam_duress.so` **or** rely on
  system-auth if included.
- Re-test COSMIC login after any PAM change.

### hyprlock

- Check:

  ```bash
  cat /etc/pam.d/hyprlock 2>/dev/null || echo "no dedicated hyprlock pam file"
  ```

- If hyprlock uses system-auth, unlock inherits duress automatically.
- Test: normal password (no wipe) vs duress password (scripts run, unlock still works).

## User configuration (after PAM is enabled)

As the end user (not root, for personal scripts):

```bash
hyprwave-duress-setup
# or non-interactive-ish:
hyprwave-duress-setup --wipe-template
hyprwave-duress-setup --status
hyprwave-duress-setup --list
```

Global (root) scripts:

```bash
sudo hyprwave-duress-setup --system --wipe-template
```

Rules from upstream:

- Scripts live in `~/.duress/` (user) or `/etc/duress.d/` (global)
- Mode must be `500`, `540`, or `550`
- Each script needs a matching `script.sha256` from `duress_sign`
- Env var for scripts: `PAMUSER`

## Test plan (disposable VM)

| # | Action | Expected |
|---|---|---|
| 1 | Login with **normal** password, no signed scripts | Success, no wipes |
| 2 | Sign wipe template with `hyprwave-duress-setup` | `.sha256` created |
| 3 | Login / unlock with **normal** password | Success, secrets **intact** |
| 4 | Login / unlock with **duress** password | Success, secrets **wiped**, no error UI |
| 5 | Wrong password | Fail as usual |
| 6 | Repeat on COSMIC greeter if enabling for both variants | Same as 3–5 |
| 7 | `bootc container lint` / image build still green | No packaging regression |

## Disable / rollback

```bash
sudo cp /etc/pam.d/system-auth.bak.TIMESTAMP /etc/pam.d/system-auth
# or remove the pam_duress.so line only
```

Removing signed scripts:

```bash
hyprwave-duress-setup --list
hyprwave-duress-setup --remove 00-wipe-sensitive.sh
```

## Hard no’s

- Do **not** enable by default in CI or release images without an explicit product decision.
- Do **not** ship pre-signed scripts or shared default duress passwords.
- Do **not** use `required` for `pam_duress.so` unless you have tested missing-module behavior.
- Do **not** rely on duress as the only protection for classified or high-value data.

## Integrator checklist

- [ ] `build-duress.sh` wired in Containerfile builder stage
- [ ] `build.sh.snippet` applied (templates + setup tool + empty `/etc/duress.d`)
- [ ] `ENABLE.md` installed under `/usr/share/hyprwave/duress/ENABLE.md`
- [ ] **No** unconditional PAM edits in build.sh
- [ ] VM test matrix above executed before documenting “supported”
