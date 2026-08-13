# Duress Password

**Status: OFF by default in the stock image.** Duress is not enabled. Do not treat login as having a wipe/duress password.

Packaging for a future optional setup may exist in the tree. **PAM is never turned on as a default login path.** This Assistant does not enable it.

## Design (summary — not active today)

- Normal password → normal session.
- A future duress password would look like a normal login while running operator-defined scripts.

## What to do today

- Use a strong login password and lock the session (Hyprland: Super+Shift+L).
- Keep sensitive data encrypted; minimize unlocked secrets at rest.
- Prefer Flatpak sandboxing and the immutable base for day-to-day hardening.

## This Assistant

This article is informational only. The Assistant does **not** configure PAM or duress passwords.
