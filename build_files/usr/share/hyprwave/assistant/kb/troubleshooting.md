# Troubleshooting

## After an update something broke

1. Confirm what is booted: `bootc status`
2. Roll back to the previous deployment if needed, then reboot.
3. Note whether the issue is **base** (all users) or **home config** (one user).

## Config feels wrong after image change

`/etc/skel` only applies to **new** users. Existing homes keep old configs.

- Diff against `/etc/skel/.config/...`
- Or create a fresh test user to see current defaults.
- Theme issues: `hyprwave-theme list` / `hyprwave-theme set <name>`

## Walker shows no apps / missing icons

- Ensure the elephant daemon is running (autostart).
- Icon cache: `gtk-update-icon-cache -f /usr/share/icons/hicolor` (image builds should already do this).

## Flatpak install fails

- Check network and Flathub remote: `flatpak remotes`
- Retry: `flatpak install -y flathub <app-id>`
- Prefer FlatArcade or this Assistant’s Installer for curated IDs.

## bootc upgrade needs root

Use `sudo bootc upgrade`. The Assistant retries with `sudo -n` when not root; configure sudoers or run from a root shell if non-interactive sudo is denied.

## Reporting bugs

Include:

- `bootc status` (image ref + digests)
- Variant (Hyprland vs COSMIC)
- Steps to reproduce
- Whether the issue survives a new user account
