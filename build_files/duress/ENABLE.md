# Enabling Hyprwave Duress (ADMIN / INTEGRATOR ONLY)

This file is the image-local copy of the enable procedure. The canonical
integration copy is `planning/integration/d-duress/ENABLE.md` (kept in sync).

**Default: OFF.** Packaging alone does not activate duress authentication.

## Quick path (Fedora / ublue)

1. Backup PAM:

   ```bash
   sudo cp -a /etc/pam.d/system-auth "/etc/pam.d/system-auth.bak.$(date +%Y%m%d%H%M%S)"
   ```

2. After the `pam_unix` auth line in `/etc/pam.d/system-auth`, add:

   ```
   auth       sufficient                  pam_duress.so
   ```

3. Keep a root session open. Test in a disposable VM.

4. User opt-in:

   ```bash
   hyprwave-duress-setup
   hyprwave-duress-setup --status
   ```

## Login managers

| Component | Notes |
|---|---|
| SDDM | Often uses `system-auth`; greeter-only alternative is `/etc/pam.d/sddm` |
| cosmic-greeter / greetd | Check `/etc/pam.d/greetd` (and `cosmic-greeter` if present) |
| hyprlock | Uses PAM; inherits system-auth when included |

Reference snippets: `/usr/share/hyprwave/duress/pam.d/` (after packaging install).

## Hard rules

- Prefer `sufficient`, not `required`, for `pam_duress.so`.
- Never ship pre-signed scripts or a shared default duress password.
- Fail-safe stock state: no PAM line + no signatures = normal auth only.

Full test plan, rollback, and threat model: see sibling `README.md` and the
repo file `planning/integration/d-duress/ENABLE.md`.
