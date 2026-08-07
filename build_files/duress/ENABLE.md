# Enabling Hyprwave Duress (ADMIN / INTEGRATOR ONLY)

This file is the image-local copy of the enable procedure. The full copy is
`planning/integration/d-duress/ENABLE.md` (kept in sync for Wave 2).

**Default: OFF.** Packaging alone does not activate duress authentication.  
There is no supported `DURESS=enable` image build mode (assets only).

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
| AGGRESSIVE | `00-wipe-sensitive.sh` | `--wipe-template` |

## Hard rules

- Prefer `sufficient`, not `required`, for `pam_duress.so`.
- Never ship pre-signed scripts or a shared default duress password.
- Fail-safe stock state: no PAM line + no signatures = normal auth only.
- Re-check PAM after `bootc upgrade` if vendor files refresh.

Full test plan, rollback, Atomic notes: sibling `README.md` and
`planning/integration/d-duress/ENABLE.md`.
