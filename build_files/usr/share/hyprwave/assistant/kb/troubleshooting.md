# Troubleshooting

## After an update something broke

1. Confirm what is booted: `bootc status`
2. Roll back to the previous deployment if needed, then reboot yourself.
3. Note whether the issue is **base** (all users) or **home config** (one user).

```bash
hyprwave-assistant status
# or
bootc status
```

## Config feels wrong after image change

`/etc/skel` only applies to **new** users. Existing homes keep old configs.

- Diff against `/etc/skel/.config/...`
- Or create a fresh test user to see current defaults.
- Theme issues: `hyprwave-theme list` / `hyprwave-theme set <name>`

## Offline mode

If the Assistant shows **OFFLINE / cannot reach network**:

- **Still works:** Knowledge Base, catalog browsing, dry-run plans
- **Blocked:** `bootc upgrade`, `flatpak update/install` (need registry/Flathub)

Fix connectivity, then retry. No reboot is forced by the Assistant.

## Walker shows no apps / missing icons (Hyprland)

- Ensure the elephant daemon is running (autostart).
- Icon cache: `gtk-update-icon-cache -f /usr/share/icons/hicolor`
- Restart Walker: `systemctl --user restart app-walker@autostart.service`

## Wallpaper wrong or blank (Hyprland)

- See the hyprpaper article.
- Re-apply theme: `hyprwave-theme set <name>`
- Check `~/.config/hypr/hyprpaper.conf` paths exist on disk.

## Flatpak install fails

- Check network and Flathub: `flatpak remotes`
- Dry-run first: `hyprwave-assistant install <id> --dry-run`
- Retry: `flatpak install -y flathub <app-id>`
- Prefer FlatArcade for full Flathub browse.

## bootc upgrade needs privileges

Use `sudo bootc upgrade`. The Assistant retries with `sudo -n` when not root. If polkit/password is required, run from a root shell or configure sudoers — failures are reported with clear privilege errors.

CLI mutations need **double confirm**:

```bash
hyprwave-assistant update --dry-run
hyprwave-assistant update --yes --confirm
```

## Reporting bugs

Include:

- `bootc status` (image ref + digests)
- Variant (Hyprland vs COSMIC)
- `hyprwave-assistant version`
- Steps to reproduce
- Whether the issue survives a new user account
