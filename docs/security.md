# Security overview

High-level security posture for Hyprwave users. This is not a formal threat model or
audit report.

---

## Immutable core

The OS base is a **bootc** image: system software under `/usr` comes from a signed,
versioned container deployment rather than an always-mutable package tree.

| Property | Benefit | Limit |
|----------|---------|--------|
| Reproducible deployments | Same image ref → same base files | You still trust the registry and build pipeline |
| Harder silent system drift | Random `/usr` edits do not “stick” across upgrades | Local `/etc` and `/var` still matter |
| Atomic updates + rollback | Bad update can often be rolled back | User data in `/home` is not rolled back with the OS |

Verify image provenance when your project publishes Cosign signatures (public key in-repo
as `cosign.pub` for published builds). Exact verify commands depend on how your host
consumes signed bootc images.

---

## Privacy-oriented defaults (companions)

- **Neonwolf** — privacy-focused Firefox fork (LibreWolf-based overlay); stock Firefox is
  removed from the image in favor of this browser.
- **FlatArcade** — installs apps from Flathub as Flatpaks (sandboxed to Flatpak’s model;
  still review permissions for sensitive apps).
- Network stack and firewall follow the Universal Blue / Fedora Atomic base; harden
  further if your threat model requires it.

---

## Authentication (stock image)

| Component | Role |
|-----------|------|
| SDDM (Hyprland image) | Graphical login |
| cosmic-greeter (COSMIC image) | Graphical login |
| hyprlock (Hyprland) | Session lock |
| User passwords | Normal Linux accounts created at install |

Stock Hyprwave does **not** enable experimental dual-password or wipe-on-login features.

---

## Duress password — optional, off by default

A **duress** (coercion) password feature may appear in the project as **packaged assets**
or contributor documentation. Even when those files land in the repository:

- It is **off by default**.
- It is **not** part of the normal install path in [INSTALL.md](../INSTALL.md).
- Enabling it is a deliberate, high-risk operator choice (PAM changes, potential data
  loss scripts) and must follow maintainer **ENABLE** docs after security review.
- This page intentionally does **not** paste enable steps. Do not assume any second
  password exists on a fresh install.

If you never ran a duress setup tool, your login password behaves like any other Fedora
Atomic system.

---

## Hyprwave Assistant (when present)

A future **Hyprwave Assistant** TUI may wrap `bootc` / Flatpak update flows. Treat it as
a convenience UI: confirm any action that upgrades the base OS or installs software, and
expect a **reboot** after base upgrades. It is not a substitute for understanding
[updating.md](updating.md). Until it is merged into the published image and listed in
the changelog as shipped, do not expect `/usr/bin/hyprwave-assistant` on disk.

---

## What Hyprwave does not claim

- Full disk encryption setup (use the installer’s / your base’s LUKS options if offered).
- Verified boot / Secure Boot policy unique to Hyprwave (inherits base + your firmware).
- Hostile multi-tenant hardening out of the box.
- Protection against an attacker who already has your unlocked session or disk key.

---

## Practical habits

1. Keep the base updated: `sudo bootc upgrade` + reboot ([updating.md](updating.md)).  
2. Prefer Flatpaks for untrusted desktop apps; review portal permissions.  
3. Use a strong login password; lock the session (Hyprland: Super+Shift+L).  
4. Do not run untrusted scripts as root; image layering is powerful and persistent.  
5. For GHCR installs, prefer official published tags and signatures when available.

---

## Related

- [architecture.md](architecture.md) — bootc / skel model  
- [troubleshooting.md](troubleshooting.md) — login and pull failures  
- [CHANGELOG.md](../CHANGELOG.md) — what actually ships  
