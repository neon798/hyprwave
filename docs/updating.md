# Updating Hyprwave

Hyprwave separates **base OS** updates (immutable image) from **app** updates (Flatpak and
anything you install in your home).

---

## Base OS (`bootc`)

### Check what you are running

```bash
bootc status
```

Note the image reference (e.g. `ghcr.io/neon798/hyprwave:latest` vs `hyprwave-cosmic`)
and whether a new deployment is already staged.

### Pull newer layers (same image ref)

```bash
sudo bootc upgrade
sudo systemctl reboot
```

Use this for day-to-day “get the latest Hyprwave build” when CI has pushed a new
`:latest` (or other tag you track).

### Change variant or image URL

```bash
# Hyprland
sudo bootc switch ghcr.io/neon798/hyprwave:latest

# COSMIC
sudo bootc switch ghcr.io/neon798/hyprwave-cosmic:latest

sudo systemctl reboot
```

`switch` changes the **target image**; `upgrade` refreshes the **current** target.

### After reboot

1. `bootc status` — confirm the booted deployment.  
2. Log in (SDDM or cosmic-greeter).  
3. Remember: **`/etc/skel` does not re-copy into existing homes.** New defaults only
   apply to new users unless you merge them yourself ([architecture.md](architecture.md)).

### Rollbacks

bootc / rpm-ostree style systems keep previous deployments. If an update misbehaves,
use your base’s documented rollback (often selecting an older deployment at boot or via
`bootc` / `rpm-ostree` rollback commands). Exact UI depends on the host; keep a recovery
path before major switches.

---

## Flatpak apps

Companion store UI: **FlatArcade** (`flatarcade`, or Super+A on Hyprland).

CLI:

```bash
flatpak update
flatpak update --user    # if you use per-user installs
flatpak list
```

Flatpak updates do **not** replace the base OS image and usually do **not** require a
full system reboot (restart the app).

---

## What you should not expect

| Approach | On Hyprwave |
|----------|-------------|
| `dnf upgrade` the whole desktop | Not how the immutable base is maintained |
| Editing files under `/usr` and expecting them to stick | Next image deploy overwrites `/usr` |
| “Update” rewriting your `~/.config` | It will not — by design |

Layered packages (`rpm-ostree install` / local layering, if you use them) follow Atomic
rules: they ride along with deployments and still need a reboot when the base changes.

---

## Pin philosophy (reproducible builds)

Image **builds** should pin versions of externally downloaded binaries (Yazi, Neonwolf,
FlatArcade) so two builds of the same git commit fetch the same artifacts. That work
lives in the packaging/stabilizer lane (`build_files/versions.env` and related), not in
end-user update commands.

**As a user you do not edit pins.** You just:

```bash
sudo bootc upgrade && sudo systemctl reboot
```

If a published image cannot be pulled, see [troubleshooting.md](troubleshooting.md)
(GHCR private / auth).

---

## Suggested cadence

1. **Weekly or when notified:** `sudo bootc upgrade` → reboot when convenient.  
2. **Apps:** open FlatArcade or `flatpak update` more often if you install many Flatpaks.  
3. **After major image news:** read [CHANGELOG.md](../CHANGELOG.md) for behavior changes
   (themes, greeter, default apps).

---

## Related

- [INSTALL.md](../INSTALL.md) — first install and variant switch  
- [troubleshooting.md](troubleshooting.md) — failed pulls, bad deployments  
- [architecture.md](architecture.md) — why reboot + skel work this way  
