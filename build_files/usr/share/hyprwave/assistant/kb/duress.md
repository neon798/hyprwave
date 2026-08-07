# Duress Password

**Status: coming soon**

A duress password is planned as an optional security feature for Hyprwave. It is **not** enabled in the base image until packaging and security review land.

## What it will do (design)

- Normal password → normal session.
- Duress password → session that looks normal while running operator-defined scripts (for example wiping sensitive paths).

## What to do today

- Do not rely on duress until the setup tool ships and you have tested it on a disposable account.
- Keep sensitive data encrypted and minimize what is stored unlocked at rest.
- Prefer Flatpak sandboxing and the immutable base for day-to-day hardening.

## Tracking

Implementation is tracked as a separate workstream (PAM module + setup tool). When available, setup will be documented here and linked from the Assistant.
