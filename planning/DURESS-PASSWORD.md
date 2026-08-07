# Duress Password Implementation Plan (Theory Only)

**Status**: Planning / Theoretical. All content is for reference. Implementation must go through Claude handoff verification before touching main tree (per project rules).

## Overview & Goals

A duress password allows a user under coercion to enter a special password that:
- Successfully authenticates (looks like normal login).
- Triggers background actions (e.g. secure deletion of sensitive data).
- Does **not** alert the coercer that anything unusual happened.

This is especially relevant for users of privacy-focused distros like Hyprwave.

### Requirements
- Works for both variants:
  - Hyprland + SDDM
  - COSMIC + cosmic-greeter (greetd-based)
- Integrates cleanly with existing PAM setup.
- Easy for users to configure their own duress password(s).
- Default safe actions that wipe sensitive user data.
- Optional advanced actions (alerts, etc.) via user scripts.
- Support for hyprlock (screen lock) where possible.
- Maintains the "looks normal" property.
- Compatible with immutable bootc model (no fragile state).

## Recommended Implementation: PAM Duress

Use the open-source **PAM Duress** module:
- https://github.com/nuvious/pam-duress

### Why this module?
- Designed exactly for this use case.
- Supports multiple duress passwords per user.
- Each duress password can be tied to signed scripts that execute on use.
- After running duress scripts, authentication succeeds normally (user logs in to their session).
- Scripts run as root or the user (configurable via signing).
- Transparent to the login manager.

Alternatives considered (and rejected for main plan):
- Custom SDDM QML hack: fragile, doesn't work for cosmic-greeter or hyprlock.
- Pure user-space password wrapper: bypasses PAM, less secure.
- Full LUKS duress (different keyslot): powerful but complex for bootc + user experience issues.

## High-Level Architecture

1. **Build Time (in build.sh)**:
   - Install build dependencies.
   - Compile and install `pam_duress.so` (from source in a builder stage, similar to hypr-utils).
   - Deploy default PAM configuration snippets.
   - Deploy default duress scripts and config directories.
   - Install a user setup tool: `hyprwave-duress-setup`.

2. **Runtime**:
   - PAM stacks for SDDM and greetd include `pam_duress.so`.
   - User configures 1+ duress passwords + associated scripts.
   - On duress login: scripts execute (e.g. data wipe), then normal session starts.
   - On normal password: normal behavior.

3. **Screen Lock**:
   - hyprlock uses PAM → will automatically support duress if configured.
   - On duress unlock: same wipe scripts run.

4. **COSMIC Variant**:
   - cosmic-greeter uses greetd PAM stack.
   - Same module works.

## Theoretical Files (in planning/theoretical/duress/)

### PAM Configuration Examples

**For SDDM (Hyprland variant)**:
`etc/pam.d/sddm` (or drop-in via /etc/pam.d/sddm.d/)

```
#%PAM-1.0
auth     [success=2 default=ignore]      pam_unix.so
auth     [success=1 default=ignore]      pam_duress.so
auth     requisite                       pam_deny.so
...
```

**For greetd / cosmic-greeter**:
Similar stack in `etc/pam.d/greetd` or `etc/pam.d/cosmic-greeter`.

### Default Duress Scripts

`etc/duress.d/00-wipe-sensitive.sh` (example):

```bash
#!/bin/bash
# Runs on duress password use.
# Securely wipe common sensitive locations.

TARGETS=(
    "$HOME/.ssh"
    "$HOME/.gnupg"
    "$HOME/.local/share/keyrings"
    "$HOME/Documents"
    "$HOME/.mozilla"
    "$HOME/.config/chromium"
    "$HOME/.config/BraveSoftware"
)

for target in "${TARGETS[@]}"; do
    if [ -d "$target" ]; then
        # Use shred or srm if available for better security
        find "$target" -type f -exec shred -vfz -n 3 {} + 2>/dev/null || rm -rf "$target"
    fi
done

# Optional: clear clipboard, notify (but carefully)
# echo "DURESS TRIGGERED" | systemd-cat -t hyprwave-duress

# For extra paranoia (comment out if not desired):
# poweroff
```

Make scripts executable and properly signed per pam-duress docs.

### User Configuration

`etc/duress.conf` (global example) and per-user in `~/.duress/` or similar.

The module uses password + script pairs signed with the duress password.

### Setup Tool

`usr/local/bin/hyprwave-duress-setup`:

Interactive tool that:
- Prompts for duress password(s).
- Creates signed scripts.
- Updates per-user config.
- Optionally sets up a decoy "clean" session view.

## Changes Needed in build.sh (Theoretical)

In the shared section or per-variant:

```bash
### Duress password support (PAM module)
# Build pam-duress in hyprbuilder stage or dedicated stage
dnf5 install -y gcc pam-devel git
# (in builder) git clone https://github.com/nuvious/pam-duress
# make && make install

# Deploy configs
cp -r /ctx/etc/duress.d /etc/
chmod +x /etc/duress.d/*.sh

# PAM integration
# For SDDM
cat > /etc/pam.d/sddm <<'PAMEOF'
... (see theoretical file)
PAMEOF

# For cosmic-greeter / greetd (similar)
```

Also ensure the module .so is in /lib64/security/

## Duress Actions for Hyprwave

Recommended defaults:
1. **Wipe sensitive data** (as above).
2. **Clear recent history** (bash, yazi, etc.).
3. **Optional poweroff** or "fake desktop" (advanced, via script that starts a limited session).
4. **Wipe clipboard and temporary files**.

User can add their own scripts (e.g. send Pushover/Signal via pre-configured tokens, but this requires careful setup to avoid leaking under duress).

## Risks & Mitigations

- **Attacker knows about duress**: Mitigation — document that duress passwords should be non-obvious and never mentioned.
- **Scripts leave traces**: Use `shred`, run as early as possible.
- **Network actions during login**: Risky (timing, logs). Prefer offline wipes. Alerts should be fire-and-forget.
- **Immutable image**: Duress scripts live in /etc (writable on runtime) or user home.
- **COSMIC differences**: Test that greetd PAM works identically.
- **hyprlock**: Verify duress works on unlock (PAM path).

## Testing Plan (after implementation)

1. Set normal password + duress password.
2. Login with normal → everything works.
3. Login with duress → data wiped, session starts normally.
4. Repeat for hyprlock.
5. Test on both variants (build two images).
6. `bootc container lint` still passes.

## Open Questions

- Should duress also affect LUKS? (Separate concern — can be layered.)
- Default behavior: wipe + continue, or wipe + fake limited desktop?
- Packaging: build from source every time or find/maintain a COPR/Fedora package?
- User onboarding: should first-boot wizard offer duress setup?

## Next Steps (for Claude Handoff)

1. Review this doc + theoretical files.
2. Decide on exact default actions.
3. Implement in build.sh (shared + per-variant sections).
4. Add to `build_files/build.sh` the compilation + deployment.
5. Create user-facing `hyprwave-duress-setup` tool.
6. Update documentation (README, CLAUDE.md).
7. Test in VM for both variants.
8. Ensure no behavior change for users who don't configure duress.

## References

- https://github.com/nuvious/pam-duress
- LWN article on PAM Duress
- Existing Hyprwave SDDM and cosmic-greeter setup in build.sh

---

**This is 100% theoretical planning.** No changes to main files.
