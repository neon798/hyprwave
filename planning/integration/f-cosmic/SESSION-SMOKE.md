# COSMIC first-login session smoke checklist

**Variant:** `hyprwave-cosmic` (`DE=cosmic`)  
**Task:** F-W1-001 · **Wave 2 refresh:** F-W2-001  
**Stamped:** 2026-08-13  
**How to get a session:** `just build-cosmic` then `just build-qcow2-cosmic` / `just run-vm-qcow2-cosmic`, or ISO via `just build-iso-cosmic`.  
**User under test:** brand-new account (vendor `/usr/share/cosmic` + `/etc/skel` only — not an upgraded home).

Mark each item **PASS / FAIL / SKIP** with a one-line note. Failures that only affect greeter go to `GREETER.md` known limits, not this list, unless session never starts.

### Dock favorites (vendor truth — must match)

Vendor file `build_files/usr/share/cosmic/com.system76.CosmicAppList/v1/favorites`
(image: `/usr/share/cosmic/.../favorites`) — **six** desktop IDs, in order:

1. `neonwolf`
2. `flatarcade`
3. `com.mitchellh.ghostty`
4. `com.system76.CosmicFiles`
5. `hyprwave-theme`
6. `com.system76.CosmicSettings`

`hyprwave-theme` is **required** on the COSMIC dock (not optional).

---

## Pre-flight (image / VM)

1. **Image tag** — Container is `localhost/hyprwave-cosmic:latest` (or `ghcr.io/<owner>/hyprwave-cosmic:latest`).  
   - *How:* `podman images | grep hyprwave-cosmic` or bootc status inside guest.

2. **Display manager** — `display-manager.service` → `cosmic-greeter.service`, unit enabled.  
   - *How:* `systemctl status display-manager.service cosmic-greeter.service`

3. **Declutter packages absent** — `cosmic-store`, `cosmic-edit`, `cosmic-player`, `cosmic-wallpapers` not installed.  
   - *How:* `rpm -q cosmic-store cosmic-edit cosmic-player cosmic-wallpapers` → all “not installed”.

4. **Session-critical packages present** — `cosmic-session`, `cosmic-comp`, `cosmic-panel`, `cosmic-settings`, `cosmic-term`, `cosmic-greeter`, `ghostty` installed.  
   - *How:* `rpm -q …`

5. **Vendor wallpaper staged** — `/usr/share/backgrounds/hyprwave/default.png` readable and matches Hyprwave default art.  
   - *How:* `file /usr/share/backgrounds/hyprwave/default.png` (PNG); visual check after login.

6. **Vendor config layer present** — `/usr/share/cosmic/com.system76.CosmicAppList/v1/favorites` and theme trees exist.  
   - *How:* `test -f` those paths; `wc -l` favorites shows six IDs.

---

## Greeter → session

7. **Login screen appears** — After boot, cosmic-greeter shows user list / password field without falling back to a text console.  
   - *Note:* Greeter wallpaper/branding limits → `GREETER.md`.

8. **Session starts** — Password accepted → COSMIC desktop (panel + dock + wallpaper), no black screen loop.  
   - *How:* `echo $XDG_CURRENT_DESKTOP` contains `COSMIC` (case may vary); `pgrep -a cosmic-session`.

---

## First-login desktop identity

9. **Wallpaper** — Desktop background is Hyprwave `default.png` (synthwave), not Fedora stock cosmic-wallpapers.  
   - *How:* Visual; or read `~/.config/cosmic/com.system76.CosmicBackground/v1/all` if user copied defaults, else vendor path above.

10. **Dark synthwave chrome** — Panel/dock/windows use dark purple base (`#15052e` family), pink accent, cyan window hints — not stock blue COSMIC.  
    - *How:* Visual; Settings → Desktop → Appearance shows dark theme active.

11. **Dock favorites (all six)** — Dock (or app list favorites) includes, in vendor order:
    - Neonwolf (`neonwolf`)
    - FlatArcade (`flatarcade`)
    - Ghostty (`com.mitchellh.ghostty`)
    - COSMIC Files (`com.system76.CosmicFiles`)
    - Hyprwave Themes (`hyprwave-theme`) — **required**, not optional
    - COSMIC Settings (`com.system76.CosmicSettings`)
    - *How:* Visual dock; or `cat /usr/share/cosmic/com.system76.CosmicAppList/v1/favorites` if user has no override.

12. **Neonwolf launches** — Favorite opens the browser (extracted AppImage under `/usr/lib/neonwolf`).  
    - *How:* Click dock icon; window appears.

13. **Ghostty launches** — Terminal opens with Hyprwave-oriented colors from skel (`~/.config/ghostty` from `/etc/skel`).  
    - *How:* Click dock; `echo $TERM` works.

14. **FlatArcade launches** — Opens in Ghostty as Flathub TUI (not cosmic-store).  
    - *How:* Click dock; no “command not found”; no residual cosmic-store icon required.

15. **COSMIC Files + Settings** — Both open native COSMIC apps from dock.

16. **Theme switcher available** — `hyprwave-theme list` works; `hyprwave-theme set <name>` updates COSMIC colors + wallpaper into `~/.config/cosmic/` without logout (best-effort daemon restart).  
    - *How:* `hyprwave-theme list`; switch to e.g. `fjord-dark` then back to `hyprwave`.

17. **Skel theme indirection** — New user has `~/.config/hyprwave/theme` → `/usr/share/hyprwave/themes/hyprwave`.  
    - *How:* `readlink -f ~/.config/hyprwave/theme`

18. **Yazi available** — `yazi` runs inside Ghostty (shared install; skel yazi config if present).  
    - *How:* `ghostty -e yazi` or from shell.

19. **No Hyprland-only chrome** — No waybar/walker/mako required for a working session; COSMIC panel/launcher/notifications own the shell.  
    - *How:* `pgrep waybar` / `pgrep walker` should be empty on a pure COSMIC login.

20. **cosmic-term still present but not promoted** — `rpm -q cosmic-term` OK; not required on dock.  
    - *Why:* session hard-dep; Ghostty is the intentional default terminal UX.

---

## Negative / regression probes

21. **cosmic-store gone** — Launcher search for “COSMIC Store” / `cosmic-store` finds nothing usable.  
22. **User override wins** — After `hyprwave-theme set vaporwave`, favorites remain; wallpaper/theme change under `~/.config/cosmic/` and survive a logout/login.

---

## Sign-off

| Field | Value |
|---|---|
| Tester | |
| Image digest / tag | |
| Date (UTC) | |
| Result | ☐ all critical PASS · ☐ FAIL (list IDs) |

**Critical for ship:** items 2–5, 7–15, 21.  
**Nice-to-have:** 16–18, 22, greeter wallpaper polish.

---

## Theme switch + wallpaper (COSMIC) — F-W1-002

Use a logged-in COSMIC session (or a VM with GUI). Theme packs live under
`/usr/share/hyprwave/themes/<name>/`. Matrix: `THEME-COSMIC-MATRIX.md`.

### Pre-checks (image, no GUI required)

23. **Theme store present** — `ls /usr/share/hyprwave/themes | wc -l` ≥ 11; each has `cosmic/config/com.system76.CosmicTheme.Dark/v1/is_dark` = `true`.  
24. **Repo path script** (on build host, not guest) — `planning/integration/f-cosmic/check-vendor-paths.sh` exits 0.

### Switcher behavior

25. **List themes** — `hyprwave-theme list` prints all pack names including `hyprwave`, `vaporwave`, `fjord-dark`, `verdant-haven`.  
26. **Switch to vaporwave** — `hyprwave-theme set vaporwave`  
    - Desktop chrome accent shifts (pink vaporwave, not hyprwave magenta alone).  
    - `~/.config/cosmic/com.system76.CosmicBackground/v1/all` contains  
      `Path("/usr/share/hyprwave/themes/vaporwave/wallpapers/wallpaper-2560x1440.jpg")`  
      (or another resolvable file under that theme’s `wallpapers/`).  
    - `~/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark` is `true`.  
    - `~/.config/cosmic/com.system76.CosmicTheme.Dark/v1/name` is `"vaporwave"`.  
27. **Wallpaper file readable** —  
    `test -r "$(grep -oP 'Path\("\K[^"]+' ~/.config/cosmic/com.system76.CosmicBackground/v1/all)"`  
28. **Dock favorites preserved** — After switch, dock still shows Neonwolf / FlatArcade / Ghostty / Files / Settings (AppList not overwritten by pack).  
    - *How:* visual; or confirm pack has no `com.system76.CosmicAppList` tree  
      (`test ! -d /usr/share/hyprwave/themes/vaporwave/cosmic/config/com.system76.CosmicAppList`).  
29. **Switch to fjord-dark** — `hyprwave-theme set fjord-dark` — Nord-like blue accent; wallpaper under `themes/fjord-dark/wallpapers/`.  
30. **Scene wallpaper (verdant-haven)** — `hyprwave-theme set verdant-haven forest`  
    - Background path ends with `wallpaper-forest-2560x1440.jpg` (or another `forest` resolution if 2560 missing).  
31. **Return to default pack** — `hyprwave-theme set hyprwave`  
    - User Background may point at theme JPG (`wallpaper-2560x1440.jpg`) rather than vendor  
      `/usr/share/backgrounds/hyprwave/default.png` — both are on-brand; first-boot only uses backgrounds path.  
32. **Survive logout/login** — After switch, log out and back in: theme colors + wallpaper still from `~/.config/cosmic` (user wins over `/usr/share/cosmic`).

### First-boot vs post-switch wallpaper paths

| Moment | Typical `CosmicBackground` Path | Source of truth |
|---|---|---|
| Brand-new user, never ran switcher | `/usr/share/backgrounds/hyprwave/default.png` | Vendor `/usr/share/cosmic/.../all` |
| After `hyprwave-theme set <name>` | `/usr/share/hyprwave/themes/<name>/wallpapers/…` | Written into `~/.config/cosmic/` by switcher |

Both files must exist on the installed image. Smoke **#5** covers staged default; **#26–#30** cover switcher paths.

### Criticality

| Items | Priority |
|---|---|
| 23–24, 26–28, 31 | **Critical** for “COSMIC feels on-brand” after theme use |
| 25, 29–30, 32 | Nice-to-have / extended |

Update sign-off Result if any of 23–28 fail.

---

## Day-1 apps: FlatArcade / Ghostty / Neonwolf (F-W1-003)

Refined launch + network checks for the COSMIC dock story. Cross-ref `DECLUTTER.md`
(store → FlatArcade) and vendor favorites order.

### Binaries and desktop files (guest CLI)

33. **FlatArcade on PATH** — `command -v flatarcade` → `/usr/bin/flatarcade`; binary executable.  
34. **FlatArcade desktop entry** — `test -f /usr/share/applications/flatarcade.desktop` and  
    `grep -E '^Exec='` shows `ghostty -e flatarcade` (TUI in Ghostty, not cosmic-store).  
35. **Neonwolf launcher** — `command -v neonwolf`; `test -x /usr/lib/neonwolf/AppRun` (extracted AppImage).  
36. **Neonwolf desktop entry** — `neonwolf.desktop` exists; `Exec=neonwolf`.  
37. **Ghostty package + desktop** — `rpm -q ghostty`; `command -v ghostty`; desktop ID  
    `com.mitchellh.ghostty` resolvable (`gtk-launch` or desktop-file-validate if available).

### Dock / launcher UX

38. **FlatArcade from dock** — Click FlatArcade favorite → Ghostty window opens running FlatArcade  
    (ratatui Flathub browser). No cosmic-store window; no “command not found”.  
    - *Network:* listing Flathub may need working DNS/HTTPS (item 43). Offline: binary still starts UI.  
39. **Ghostty from dock** — Opens a terminal with shell prompt; skel config under `~/.config/ghostty` if new user.  
40. **Neonwolf from dock** — Browser window appears (extracted AppRun). First run may show profile chrome; must not depend on FUSE (`AppImage` already extracted at build).  
41. **COSMIC Settings from dock** — Opens; Appearance shows dark theme active (hyprwave-dark / user override).  
42. **COSMIC Files from dock** — Opens file manager; home directory listing works.

### Network (install + session)

43. **NetworkManager up** — `nmcli general status` shows state connected (or Wi-Fi radio available in VM).  
    - *ISO note:* Anaconda Network module configures install-time NIC; post-boot NM owns the stack.  
44. **DNS / HTTPS smoke** — `curl -fsSIL https://flathub.org | head -1` returns HTTP headers **or** document  
    SKIP if VM is offline; FlatArcade browse features need this for full PASS.  
45. **No cosmic-store residual** — `command -v cosmic-store` empty; launcher search does not offer COSMIC Store.

### Theme switch (refined app-preserving)

46. **Theme switch keeps apps** — `hyprwave-theme set vaporwave` then re-open Neonwolf + Ghostty from dock  
    (favorites unchanged; only colors/wallpaper change).  
47. **FlatArcade after theme switch** — Still launches via Ghostty; wallpaper may be vaporwave art underneath.

### Criticality (F-W1-003)

| Items | Priority |
|---|---|
| 33–37, 38–42, 45 | **Critical** day-1 app story |
| 43–44 | Critical if claiming online Flatpak UX; else SKIP with note |
| 46–47 | Regression / nice-to-have |

Sign-off: day-1 COSMIC ship bar includes declutter (#3) + these critical app items.

---

## Image inspect (host) — F-W2-001 / F-W2-002 / F-W3-001

**Durable card (copy-paste + digest table):** [IMAGE-INSPECT.md](./IMAGE-INSPECT.md)

Run against a built container **before** VM/ISO when `localhost/hyprwave-cosmic:latest` exists.
Does **not** replace greeter/session GUI smoke; catches packaging regressions early.
COSMIC DM is **cosmic-greeter** — do **not** require SDDM ([GREETER.md](./GREETER.md)).
ISO build: `just build-iso-cosmic` → [`disk_config/iso-cosmic.toml`](../../../disk_config/iso-cosmic.toml).

```bash
# Host pre-check
bash planning/integration/f-cosmic/check-vendor-paths.sh   # must exit 0

podman run --rm --entrypoint bash localhost/hyprwave-cosmic:latest -lc '
  rpm -q cosmic-store 2>&1 | grep -q "not installed" && echo PASS: no cosmic-store
  rpm -q cosmic-greeter ghostty && echo PASS: greeter+ghostty
  readlink -f /etc/systemd/system/display-manager.service | grep -q cosmic-greeter && echo PASS: DM=cosmic-greeter
  test ! -e /usr/lib/systemd/system/sddm.service && echo PASS: no SDDM unit
  test -f /usr/share/applications/flatarcade.desktop
  test -f /usr/share/applications/neonwolf.desktop
  test -f /usr/share/applications/hyprwave-theme.desktop
  command -v flatarcade neonwolf hyprwave-theme-gui
  grep -q flatarcade /usr/share/cosmic/com.system76.CosmicAppList/v1/favorites
  test -f /usr/share/backgrounds/hyprwave/default.png
  cat /usr/share/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark   # true
'
```

| # | Check | Expected | 2026-08-13 host result (`localhost/hyprwave-cosmic:latest`) |
|---|---|---|---|
| 48 | Image present | `podman image exists localhost/hyprwave-cosmic:latest` | **PASS** — created ~2026-08-13T03:22Z UTC, ~10.1 GB, id `189340691cc7` |
| 49 | `cosmic-store` | not installed | **PASS** |
| 50 | FlatArcade present | `flatarcade` + `.desktop` | **PASS** |
| 51 | Theme GUI present | `hyprwave-theme` / `hyprwave-theme-gui` + desktop | **PASS** |
| 52 | Neonwolf present | binary + desktop | **PASS** |
| 53 | No SDDM | no `/usr/lib/systemd/system/sddm.service` | **PASS** (cosmic-greeter is DM) |
| 54 | Vendor favorites | six IDs as above (includes `hyprwave-theme`) | **PASS** (matches tree) |
| 55 | Mode + wallpaper | `is_dark=true`; backgrounds PNG staged | **PASS** |
| 56 | Host vendor script | `check-vendor-paths.sh` exit 0 | **PASS** |

**F-W3-001 reconfirm (same image id `189340691cc7`):** rows 48–56 all **PASS** again —
no cosmic-store, DM=cosmic-greeter, no SDDM, FlatArcade + theme GUI present.
Full card + digest: [IMAGE-INSPECT.md](./IMAGE-INSPECT.md) §3.

**Docs must not claim SDDM on the COSMIC variant.** SDDM/hyprwave theme is Hyprland-only (see `GREETER.md`).
