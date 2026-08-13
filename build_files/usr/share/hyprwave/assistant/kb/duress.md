# Duress Password

**Status: optional, off by default — not enabled in the stock image.**

Duress is a separate packaging workstream. After integrator merge, operator docs live under the duress integration tree (see `ENABLE.md` / `build_files/duress/` once present on `main`).

## Design (summary)

- Normal password → normal session.
- Duress password → session that looks normal while running operator-defined scripts.

## What to do today

- Do **not** rely on duress until the setup tool ships and you have tested it on a disposable account.
- Keep sensitive data encrypted; minimize unlocked secrets at rest.
- Prefer Flatpak sandboxing and the immutable base for day-to-day hardening.

## This Assistant

This Knowledge Base entry is informational only. The Assistant does **not** configure PAM or duress passwords.
