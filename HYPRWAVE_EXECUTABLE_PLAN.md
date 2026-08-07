# Hyprwave Executable Plan
**Goal:** Get Hyprwave from early prototype to a usable, bootable, reasonably cohesive synthwave Hyprland desktop image.

**Last updated:** 2026-08-06  
**Current state:** Builds succeed daily via CI, but last meaningful code changes were 2026-06-25. Image is not yet practically usable by others.

---

## Phase 1: Make the Existing Image Actually Usable
**Priority:** Critical  
**Estimated time:** 2–4 days

### 1.1 Stabilize the Build
- [ ] Clone the repository and run a local build:
  ```bash
  git clone https://github.com/neon798/hyprwave.git
  cd hyprwave
  just build hyprwave latest
  ```
- [ ] Fix any failures related to:
  - COPR availability (`ashbuk/Hyprland-Fedora`, `scottames/ghostty`)
  - GitHub rate limits or missing releases when downloading Yazi / Neonwolf / FlatArcade
- [ ] **Pin external binaries** instead of always using `:latest`:
  - Yazi
  - Neonwolf AppImage
  - FlatArcade binary
- [ ] Confirm Cosign signing works and `cosign.pub` is correct.

### 1.2 Confirm Image Publication
- [ ] Verify that CI is successfully pushing to:
  ```
  ghcr.io/neon798/hyprwave:latest
  ```
- [ ] Test pulling and switching:
  ```bash
  sudo bootc switch ghcr.io/neon798/hyprwave:latest
  ```
- [ ] If the image is not publicly available or switch fails, fix the workflow / permissions / tags.

### 1.3 First-Boot Experience
- [ ] Ensure `/etc/skel` configs produce a working Hyprland session for new users.
- [ ] Confirm SDDM starts Hyprland cleanly as the default session.
- [ ] Set defaults properly:
  - Browser → Neonwolf
  - Terminal → Ghostty
  - File manager → Yazi
- [ ] Make sure at least one wallpaper loads on startup via `swaybg`.
- [ ] Verify key services start (NetworkManager, polkit, blueman, etc.).

**Phase 1 Success Criteria**  
A user can run `sudo bootc switch ghcr.io/neon798/hyprwave:latest`, reboot, log in, and have a functional Hyprland desktop with terminal, browser, and status bar working.

---

## Phase 2: Make It Look and Feel Cohesive
**Priority:** High  
**Estimated time:** 1–2 weeks

### 2.1 Core Theming
- [ ] Define a clear synthwave84 color palette and apply it consistently to:
  - Hyprland (borders, gaps, animations, active/inactive windows)
  - Waybar
  - Wofi
  - Mako
  - Ghostty
  - GTK 3 & 4
- [ ] Ship 3–5 high-quality synthwave wallpapers under `/usr/share/hyprwave/wallpapers/`.
- [ ] Add a basic matching icon theme and cursor theme if possible.

### 2.2 Config Polish
- [ ] Clean and complete the split Hyprland configs in `build_files/etc/skel/.config/hypr/`.
- [ ] Style Waybar so it looks intentional and useful.
- [ ] Improve Wofi styling and functionality.
- [ ] Add sensible default keybinds and document them.
- [ ] Ensure autostart works reliably (applet, notifications, wallpaper, etc.).

### 2.3 Companion Apps
- [ ] Decide on FlatArcade:
  - Option A: Un-archive, fix, and re-integrate
  - Option B: Temporarily remove it from the default install
- [ ] Harden Neonwolf AppImage extraction and wrapper script.
- [ ] Confirm Neonwolf launches correctly and is set as default browser.

**Phase 2 Success Criteria**  
The desktop looks deliberately themed (not just “stock Hyprland + packages”) and feels cohesive.

---

## Phase 3: Documentation & Basic Discoverability
**Priority:** High  
**Estimated time:** 2–4 days (can run in parallel with Phase 2)

- [ ] Rewrite `README.md` with:
  - Clear install instructions (`bootc switch` + any ISO path)
  - Current screenshots
  - Default applications list
  - Basic keybinds
  - How to update
- [ ] Create `INSTALL.md` with step-by-step instructions.
- [ ] Add a short changelog or `CHANGELOG.md`.
- [ ] Take a set of good screenshots once theming is acceptable.

---

## Phase 4: Reliability & Ongoing Maintenance
**Priority:** Medium  
**Estimated time:** Ongoing

- [ ] Pin all external downloads to specific versions.
- [ ] Evaluate whether to stay on `ublue-os/base-main` or move to a richer base (Bluefin / Bazzite).
- [ ] Test on real hardware (especially NVIDIA if relevant).
- [ ] Establish a simple release process (tag versions when the image feels good).
- [ ] Keep CI healthy and watch for Fedora / Hyprland breakage.

---

## Immediate Next Actions (Do These First)

1. **Today**
   - Run a local `just build` and note any failures.
   - Check whether `ghcr.io/neon798/hyprwave:latest` is pullable.

2. **Next 1–2 days**
   - Pin the three external binaries.
   - Fix any build or first-boot issues found.
   - Update the README with the exact `bootc switch` command once the image works.

3. **This week**
   - Get a functional first-boot experience working.
   - Begin basic theming of Hyprland + Waybar + Wofi.

---

## Definition of “Working”
The project is considered “working” when:

- The image builds and is publicly available on GHCR.
- A user can switch to it and get a functional Hyprland session on first login.
- Core apps (terminal, browser, file manager, bar) work.
- The desktop has a recognizable synthwave identity (even if not fully polished).
- Basic documentation exists so others can install it.

---

*This plan prioritizes getting a usable product in users’ hands as quickly as possible, then iterating on polish and theming.*
