# Security overview

High-level security posture for Hyprwave users. This is **not** a formal certification
or a substitute for the operator threat model on the duress lane.

Sources for optional duress packaging (on `main`; PAM still **off**):

| Path | Role |
|------|------|
| `build_files/duress/THREAT-MODEL.md` | Assets, adversaries, residual risks, **non-goals** |
| `build_files/duress/ENABLE.md` / `planning/integration/d-duress/ENABLE.md` | Admin-only enable / recovery / upgrade drift |
| `planning/integration/d-duress/FAQ.md` | Operator FAQ (off-by-default meaning, LUKS vs duress) |
| `planning/integration/d-duress/DRILL.md` | Disposable VM drill |

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
consumes signed bootc images. GHCR packages may still be **private** — see
[INSTALL.md](../INSTALL.md#important-ghcr-may-be-private).

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
A fresh install has **one** normal account password. No second “duress” password exists
unless an administrator deliberately enables packaging **and** a user signs scripts.

---

## Duress password — optional, **off by default**

Hyprwave may package [nuvious/pam-duress](https://github.com/nuvious/pam-duress) **assets**
(module, `duress_sign`, templates, `hyprwave-duress-setup`, docs). Packaging is **assets
only**:

| Condition | Login behavior |
|-----------|----------------|
| Assets on disk, **no** `pam_duress` in PAM | **Unchanged** (stock) |
| PAM line present, **no** signed scripts | Module ignores; normal passwords work |
| Signed scripts, **no** PAM line | Scripts never run at login |
| PAM **and** signed scripts (admin + user opt-in) | Duress password can run background scripts |

### Hard guarantees for the handbook

- **Off by default.** There is **no** supported image build mode `DURESS=enable`.
  Build intent is assets-only documentation (`DURESS=assets` as docs language).
- Build/install paths in [INSTALL.md](../INSTALL.md) **never** turn duress on.
- **No enable steps are pasted here.** Admins who accept the risk use the ENABLE docs
  **after** a disposable VM drill and security review.
- Prefer **`auth sufficient pam_duress.so`** after `pam_unix` if ever enabling —
  **never** start with `required` (lockout risk if the module is missing).
- **Never** commit or bake `*.sha256` signature files into git or the image.
- After `bootc upgrade`, vendor PAM files may **drop** a custom line — re-check with
  operator tools; see D-lane ENABLE upgrade drift section.

If you never ran a duress setup tool and never edited PAM, your login password behaves
like any other Fedora Atomic system.

### What duress is *not* (residual risks / non-goals)

Aligned with D-lane `THREAT-MODEL.md` and FAQ:

| Claim Hyprwave does **not** make | Reality |
|----------------------------------|---------|
| “Duress replaces full-disk encryption” | **False.** Use installer / base **LUKS** (or other volume crypto) for data-at-rest. Duress is **not** a LUKS substitute. |
| “Wipe is forensic-grade” | **False.** SSD wear-leveling, snapshots, prior ostree images, and untargeted paths remain. |
| “Safe against prepared attackers” | **False.** Someone who knows duress exists, has a disk image, or controlled the machine earlier can still recover data. |
| “Second visible desktop profile” | **False.** Success is silent; no “duress mode” UI. |
| “CI automatically rewrites PAM” | **False.** Human enable only. |

**Residual risks** (if someone enables it): incomplete wipe, PAM lockout, bootc PAM
drift after upgrade, side channels, social pressure. Treat duress as raising the cost of
*live coercion* at password entry — not as magic.

### Templates (severity — packaging only)

| Severity | Template (names on D lane) | Intent |
|----------|----------------------------|--------|
| MILD | histories / local cache clear | Prefer these first |
| AGGRESSIVE | wipe-sensitive keys/profiles | High risk; VM only until trusted |

Exact file names and `hyprwave-duress-setup` flags live in D-lane ENABLE/README — not
duplicated here so this page never becomes an accidental runbook.

---

## Hyprwave Assistant (ships in the image)

**Hyprwave Assistant** is installed at `/usr/bin/hyprwave-assistant` (desktop entry
launches it in Ghostty). Hyprland: **Super+Shift+A**. Treat it as a convenience UI:
confirm any action that upgrades the base OS or installs software, and expect a
**reboot** after base upgrades. It is not a substitute for understanding
[updating.md](updating.md).

---

## What Hyprwave does not claim

- Full disk encryption **as a Hyprwave feature** (use the installer’s / base’s **LUKS**
  options if offered — separate from optional duress).
- Verified boot / Secure Boot policy unique to Hyprwave (inherits base + your firmware).
- Hostile multi-tenant hardening out of the box.
- Protection against an attacker who already has your unlocked session or disk key.
- Public GHCR pulls without maintainer package visibility (see INSTALL).

---

## Practical habits

1. Keep the base updated: `sudo bootc upgrade` + reboot ([updating.md](updating.md)).  
2. Prefer Flatpaks for untrusted desktop apps; review portal permissions.  
3. Use a strong login password; lock the session (Hyprland: Super+Shift+L).  
4. Do not run untrusted scripts as root; image layering is powerful and persistent.  
5. For GHCR installs, prefer official published tags and signatures when available.  
6. Do **not** enable experimental PAM modules on a daily driver without a recovery path.

---

## Related

- [architecture.md](architecture.md) — bootc / skel model  
- [troubleshooting.md](troubleshooting.md) — login and pull failures  
- [first-boot.md](first-boot.md) — expected stock auth after install  
- [faq.md](faq.md) — short duress Q&A  
- [CHANGELOG.md](../CHANGELOG.md) — what actually ships (duress packaging on main; PAM off)  
