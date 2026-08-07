# Parallel 4-Model Execution Plan

**Status:** Ready to run  
**Purpose:** Move Hyprwave forward fast by splitting remaining work into **four independent lanes** that never wait on each other and never edit the same files.  
**Based on:** Assessment of `HYPRWAVE_EXECUTABLE_PLAN.md` vs current tree (2026-08-06).

---

## 1. Assessment of `HYPRWAVE_EXECUTABLE_PLAN.md`

### Verdict: **Stale — do not execute as written**

The executable plan describes an early-prototype product. The working tree (committed + large uncommitted delta) has already moved far past it.

| Plan claim | Reality (tree today) |
|---|---|
| Last meaningful code ~2026-06-25 | Large uncommitted implementation: Walker, hyprpaper, theme store, COSMIC, SDDM, hypr utils builder |
| Wallpaper via `swaybg` | `swaybg` removed; `hyprpaper` + theme wallpapers |
| Launcher = Wofi | Wofi deleted; Walker + elephant plugins |
| Theming “begin later” | Full synthwave palette + **11 themes** under `/usr/share/hyprwave/themes/` |
| FlatArcade “decide later” | Shipped; COSMIC store removed; FlatArcade is default app store |
| No COSMIC | `DE=cosmic`, `just build-cosmic`, `iso-cosmic.toml`, vendor cosmic keys |
| Docs thin | README covers install, COSMIC, themes, companion apps |
| Pin external binaries | **Still open** — Yazi / Neonwolf / FlatArcade still use `/releases/latest` |
| INSTALL.md / CHANGELOG | **Missing** |
| First-boot “proven usable” | Code exists; **end-to-end VM proof + GHCR public pull** still needed |
| Duress / Assistant | Planned only (`planning/`) — not in image |

### What the old plan still correctly prioritizes

1. **Prove bootable usability** (build → publish → first login → core apps).
2. **Pin external downloads** for reproducible builds.
3. **Docs people can follow** (INSTALL + changelog + screenshots).
4. **Don’t stall on polish** before “works.”

### What should replace the old phases

| Old phase | Status | Action |
|---|---|---|
| P1 Usable image | ~90% implemented in tree | **Validate + pin + ship**, don’t re-implement |
| P2 Cohesive look | ~95% done (themes, Walker, SDDM, COSMIC keys) | Light polish only if validation finds gaps |
| P3 Docs | Partial | Dedicated lane |
| P4 Maintenance | Ongoing | Fold into Stabilizer + features |
| *New* Assistant | Designed, not built | Dedicated lane |
| *New* Duress | Designed, not built | Dedicated lane |

### Biggest risk right now (before any parallel work)

There is a **massive uncommitted working tree** (`main` ahead of origin by 1 + many modified/untracked paths).  
Four models editing that dirty tree will collide hard.

**Gate 0 (human or single lead model, ~30–90 min, once):**

1. Snapshot or commit current WIP onto a base branch (e.g. `wip/current-desktop`).
2. Push or keep as the only shared base every lane rebases/branches from.
3. Only then spawn the four models.

Without Gate 0, “four independent models” becomes four merge conflicts.

---

## 2. Parallelization principles

1. **File ownership is law** — each lane has exclusive write paths. If a change needs another lane’s file, file a `HANDOFF.md` note; do not edit.
2. **No shared choke-point edits during the wave** — especially avoid concurrent edits to:
   - `build_files/build.sh`
   - `Containerfile`
   - `Justfile`
   - `README.md` / `CLAUDE.md` / `AGENTS.md`
   - `.github/workflows/*`
3. **Integration via drop-in dirs + one integrator** — each lane deposits a self-contained patch (branch or `integration/<lane>/` snippet files). A fifth “integrator” step (or rotating human) merges once.
4. **Self-validation** — each lane must run the checks that only need its artifacts. Full image build is **not** required mid-lane unless the lane owns packaging.
5. **No waiting** — lanes never block on another lane’s PR. If something is blocked by missing shared wiring, ship the feature **dormant** (files present, not yet called from `build.sh`) and document the 3–10 line hook for the integrator.

---

## 3. Four independent models (lanes)

```
                    ┌─────────────────────────┐
                    │  GATE 0: freeze WIP     │
                    │  base branch = truth    │
                    └───────────┬─────────────┘
                                │
        ┌───────────────┬───────┴────────┬────────────────┐
        ▼               ▼                ▼                ▼
   MODEL A          MODEL B          MODEL C          MODEL D
   STABILIZER       DOCS &           ASSISTANT        DURESS
   & HARDENING      RELEASE          (Go TUI)         (PAM)
   branch:          branch:          branch:          branch:
   lane/a-…         lane/b-…         lane/c-…         lane/d-…
        │               │                │                │
        └───────────────┴───────┬────────┴────────────────┘
                                ▼
                    ┌─────────────────────────┐
                    │  INTEGRATOR (serial)    │
                    │  merge + build.sh hooks │
                    │  just build ×2 + VM     │
                    └─────────────────────────┘
```

All four models start **immediately after Gate 0**. They never join mid-flight.

---

### MODEL A — Stabilizer & Build Hardening

**Mission:** Make the *existing* image reproducible and shippable. No new product features.

**Why independent:** Only touches packaging/version pins and CI/build plumbing. Does not implement Assistant or Duress.

| | |
|---|---|
| **Branch** | `lane/a-stabilize` |
| **Time box** | 1–2 days |
| **Success** | Pins landed; CI metadata sane; checklist for first-boot; optional GHCR pull notes |

#### Exclusive write ownership

```
build_files/build.sh                 # ONLY if others freeze this file for wave 1
  → better: create build_files/pin-versions.env + patch snippet
build_files/versions.env             # NEW — pin tags/SHAs
.github/workflows/build.yml
.github/workflows/build-disk.yml
Containerfile                        # only if needed for ARG pins
Justfile                             # only if needed for build args
cosign.pub                           # verify only; edit only if broken
planning/integration/a-stabilize/    # drop-in: build.sh diffs, notes
```

**Preferred pattern (zero collision with C/D):**

- Do **not** rewrite all of `build.sh`.
- Add `build_files/versions.env` (or similar) with:
  - `YAZI_VERSION=...`
  - `NEONWOLF_VERSION=...` / AppImage URL + checksum
  - `FLATARCADE_VERSION=...` + checksum
- Put the actual `curl` URL change as a **unified diff** in `planning/integration/a-stabilize/build.sh.patch` if Model C/D might also need `build.sh` later.
- For this wave: **claim exclusive `build.sh` for Model A only** if the team agrees A is the only packager. Models C and D ship dormant assets (see below).

#### Work items

1. Replace `/releases/latest` for Yazi, Neonwolf, FlatArcade with **versioned URLs + optional sha256**.
2. Document how to bump pins (short comment or `planning/integration/a-stabilize/BUMP.md`).
3. Confirm workflows still matrix both images; fix only if broken.
4. Write `planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md` (VM steps, not full INSTALL).
5. Note GHCR pull status (`ghcr.io/neon798/hyprwave:latest` and `-cosmic`) — record pass/fail, don’t block others.

#### Forbidden

- Theme CSS / skel polish (unless a pin requires a path change).
- Implementing Assistant or Duress.
- Rewriting README (notes only under `planning/integration/a-stabilize/`).

#### Self-validation

```bash
# syntax / static
just lint
just check
# optional: full build if machine free — not required to finish the lane
grep -n 'releases/latest' build_files/build.sh   # should be empty after pin
```

---

### MODEL B — Docs & Discoverability

**Mission:** People can install and understand the distro without reading the repo.

**Why independent:** Pure documentation + screenshots placeholders. Zero product code.

| | |
|---|---|
| **Branch** | `lane/b-docs` |
| **Time box** | 1 day |
| **Success** | INSTALL.md + CHANGELOG.md + README install path accurate for current design |

#### Exclusive write ownership

```
INSTALL.md                           # NEW
CHANGELOG.md                         # NEW
docs/                                # NEW if needed (keybinds, themes)
planning/integration/b-docs/         # screenshot checklist, draft README sections
```

**README ownership rule:** Model B may edit `README.md` **only** if Models A/C/D agree not to touch it. Safer: B writes full proposed sections under `planning/integration/b-docs/README-sections.md` and the integrator applies them. Prefer that if any risk of conflict.

#### Work items

1. **INSTALL.md**
   - bootc switch for both images
   - ISO path (`just build-iso` / cosmic)
   - First login expectations (SDDM vs cosmic-greeter)
   - Update path (`bootc upgrade`)
2. **CHANGELOG.md**
   - Unreleased section describing current WIP as if about-to-ship (Walker, themes, COSMIC, companions)
3. **Keybinds quickref** (Hyprland) — Super+D/Space, Super+R, Super+Shift+T, terminal, etc.
4. **Screenshot checklist** (what to capture after VM exists) — do not block on screenshots.
5. Align language with reality: Walker not Wofi; hyprpaper not swaybg; 11 themes; both DEs.

#### Forbidden

- Any `build_files/` edits.
- “Fixing” product bugs found while writing docs — file issues under `planning/integration/b-docs/ISSUES.md`.

#### Self-validation

- Links and image refs exist or are marked TODO.
- Commands match `Justfile` recipe names.
- No mention of removed components (Wofi, swaybg, Thunar as default).

---

### MODEL C — Hyprwave Assistant (product feature)

**Mission:** Implement the Go + Bubble Tea assistant from `planning/HYPRWAVE-ASSISTANT.md` as a **self-contained package** that can be dropped into the image later.

**Why independent:** New source tree + install recipe snippet. Does not need Duress or docs lane. Does not need pinned URLs to start (can mock update commands).

| | |
|---|---|
| **Branch** | `lane/c-assistant` |
| **Time box** | 2–4 days |
| **Success** | Binary builds; TUI navigable; updater/installer/KB stubs work; dormant image integration ready |

#### Exclusive write ownership

```
apps/hyprwave-assistant/             # NEW — Go module (preferred layout)
  OR packages/hyprwave-assistant/
build_files/usr/share/hyprwave/assistant/   # NEW — KB markdown, catalog.toml
build_files/usr/share/applications/hyprwave-assistant.desktop  # NEW only this file
planning/integration/c-assistant/
  build.sh.snippet                   # install binary + data (for integrator)
  Containerfile.snippet              # only if multi-stage go build needed
  README-blurb.md
```

**Do not edit** live `build.sh` / `Containerfile` if Model A owns them — only snippets.

#### Work items (from plan, slimmed for parallel wave)

1. Scaffold Go module: Bubble Tea tabs — **Updater | Installer | Knowledge Base | About**.
2. Wire real commands where safe:
   - `bootc status` / `bootc upgrade` (with confirm + reboot warning)
   - `flatpak update` / install from catalog
3. Ship catalog TOML (reuse ideas from `planning/theoretical/hyprwave-assistant/` and old TUI catalog).
4. Ship starter KB articles (philosophy, updates, theming, variants; duress article can say “coming soon” without waiting on Model D).
5. Synthwave Lip Gloss palette; optional later hook to `hyprwave-theme`.
6. Desktop entry + suggested keybind note for integrator (do not edit `bindings.conf`).
7. Local build instructions: `go build -o hyprwave-assistant .`

#### Forbidden

- Editing Hyprland skel, Walker, Waybar, themes store.
- Implementing PAM / duress.
- Changing CI matrix.

#### Self-validation

```bash
cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .
# manual: run binary, navigate tabs, dry-run install list
```

**Dormant integration is success.** Image need not contain the binary until integrator applies the snippet.

---

### MODEL D — Duress Password (security feature)

**Mission:** Implement PAM Duress packaging + setup tool from `planning/DURESS-PASSWORD.md` as a **self-contained, off-by-default** subsystem.

**Why independent:** New PAM assets + optional builder stage files. Login managers work without it until integrator enables PAM lines.

| | |
|---|---|
| **Branch** | `lane/d-duress` |
| **Time box** | 2–3 days |
| **Success** | Module builds (or clear package path); scripts + setup tool ready; PAM snippets documented; **disabled until integrator enables** |

#### Exclusive write ownership

```
build_files/duress/                  # NEW — all duress assets
  pam.d/sddm.snippet
  pam.d/greetd.snippet
  duress.d/00-wipe-sensitive.sh
  hyprwave-duress-setup
  README.md                          # operator notes + risks
build_files/build-duress.sh          # NEW — compile pam_duress (mirrors build-hypr-utils pattern)
planning/integration/d-duress/
  build.sh.snippet
  Containerfile.snippet              # builder stage if needed
  ENABLE.md                          # exact PAM enable steps + warnings
```

**Do not edit** production `/etc/pam.d` copies inside the image until integrator review — ship snippets only.

#### Work items

1. Translate theoretical tree (`planning/theoretical/duress/`) into `build_files/duress/`.
2. `build-duress.sh`: fetch/pin `pam-duress` version, compile `.so`, install path documented.
3. Default wipe script: careful, documented, **opt-in** (setup tool installs user config; no surprise wipes on stock image).
4. `hyprwave-duress-setup`: create duress password + bind script; clear warnings.
5. Notes for hyprlock (PAM) and cosmic-greeter (greetd).
6. Security README: threat model, false sense of security, legal/ethics one-liner.

#### Forbidden

- Enabling duress by default in SDDM/greetd without human security review.
- Touching theme/assistant/docs product files.
- Weakening auth (always fail closed if module missing).

#### Self-validation

```bash
# compile path dry-run in container or document manual test
bash -n build_files/duress/hyprwave-duress-setup
bash -n build_files/duress/duress.d/00-wipe-sensitive.sh
# integration test only after integrator enables PAM in a disposable VM
```

---

## 4. File ownership matrix (collision prevention)

| Path | A | B | C | D |
|---|---|---|---|---|
| `build_files/build.sh` | **owner** (pins only) or patches-only | — | snippet only | snippet only |
| `Containerfile` / `Justfile` | owner if needed | — | snippet | snippet |
| `.github/workflows/*` | **owner** | — | — | — |
| `build_files/versions.env` | **owner** | — | — | — |
| `INSTALL.md` / `CHANGELOG.md` | — | **owner** | — | — |
| `README.md` | — | integrator or B | blurbs only | blurbs only |
| `apps/hyprwave-assistant/**` | — | — | **owner** | — |
| `build_files/usr/share/hyprwave/assistant/**` | — | — | **owner** | — |
| `build_files/duress/**` | — | — | — | **owner** |
| `build_files/build-duress.sh` | — | — | — | **owner** |
| `build_files/etc/skel/**` | — | — | — | — |
| `build_files/usr/share/hyprwave/themes/**` | — | — | — | — |
| `planning/integration/<lane>/**` | A | B | C | D |

**Skel and themes are frozen in Wave 1.** They already implement most of old Phase 1–2. Polish is Wave 2 after validation.

---

## 5. Integration protocol (serial, short)

After all four lanes open PRs / finish branches:

1. **Merge order (recommended):**
   1. **A** (pins + CI) — stabilizes the base everyone builds on  
   2. **B** (docs) — no code risk  
   3. **C** (assistant assets) + apply `build.sh.snippet`  
   4. **D** (duress assets) + apply snippet **without enabling PAM** until review  
2. Single integrator runs:
   ```bash
   just lint && just check
   just build hyprwave latest
   just build-cosmic
   # optional: just run-vm-qcow2
   ```
3. Enable duress PAM only after explicit human OK (security).
4. Update old `HYPRWAVE_EXECUTABLE_PLAN.md` status section or archive it pointing here.

**Integrator is the only role that may edit `build.sh` for feature hooks after A lands.**

---

## 6. What each model is told (copy-paste prompts)

### Prompt — Model A

> You own **lane/a-stabilize**. Base branch is `<BASE>`.  
> Pin Yazi, Neonwolf, FlatArcade away from `:latest`; prefer `build_files/versions.env` + minimal `build.sh` edits.  
> Fix CI only if broken. Write first-boot checklist under `planning/integration/a-stabilize/`.  
> Do not implement Assistant, Duress, themes, or README rewrites.  
> Exit when pins exist and `grep releases/latest build_files/build.sh` is clean.

### Prompt — Model B

> You own **lane/b-docs**. Base branch is `<BASE>`.  
> Create `INSTALL.md` and `CHANGELOG.md` matching **current** Hyprwave (Walker, hyprpaper, 11 themes, COSMIC + Hyprland, Neonwolf, FlatArcade).  
> Do not edit `build_files/` or workflows.  
> Put README patches in `planning/integration/b-docs/` if unsure about conflicts.  
> Exit when a new user could install from docs alone.

### Prompt — Model C

> You own **lane/c-assistant**. Base branch is `<BASE>`.  
> Implement Hyprwave Assistant (Go + Bubble Tea) under `apps/hyprwave-assistant/` per `planning/HYPRWAVE-ASSISTANT.md`.  
> Ship KB + catalog under `build_files/usr/share/hyprwave/assistant/`.  
> Do **not** edit `build.sh`/`Containerfile`; provide `planning/integration/c-assistant/build.sh.snippet`.  
> Do not wait for Duress or docs.  
> Exit when `go build` succeeds and TUI core flows work offline.

### Prompt — Model D

> You own **lane/d-duress**. Base branch is `<BASE>`.  
> Implement duress packaging under `build_files/duress/` + `build_files/build-duress.sh` per `planning/DURESS-PASSWORD.md`.  
> **Off by default** — snippets only, no production PAM enable.  
> Do not edit skel, themes, assistant, or docs.  
> Provide `planning/integration/d-duress/{build.sh.snippet,ENABLE.md}`.  
> Exit when setup tool + scripts are lint-clean and build recipe is documented.

---

## 7. Wave 2 (after integrator) — still parallelizable

Only start after Wave 1 merges and one green dual-variant build.

| Model | Wave 2 focus | Still independent? |
|---|---|---|
| A | VM first-boot proof both DEs; hardware notes | Yes |
| B | Screenshots + short demo GIF; website if any | Yes |
| C | Theme-aware assistant; Walker entry; keybind | Needs skel — coordinate |
| D | Optional PAM enable behind build arg `DURESS=1` | Needs build.sh — after A |

Wave 2 skel edits (keybind for assistant) are **one owner** — assign to C with freeze on other skel files.

---

## 8. Explicit non-goals for this parallel wave

- Re-doing synthwave theming from the old Phase 2 list.
- Replacing Walker or re-adding Wofi.
- Expanding theme count (11 is enough).
- Base-image migration (Bluefin/Bazzite) — serial research later.
- NVIDIA hardware certification — needs physical machine, not 4 models.

---

## 9. Definition of done (whole program)

Wave 1 done when:

- [ ] Gate 0 base branch frozen and used by all lanes  
- [ ] Model A: external binaries pinned  
- [ ] Model B: INSTALL.md + CHANGELOG.md exist and match reality  
- [ ] Model C: Assistant builds and integration snippet ready  
- [ ] Model D: Duress assets packaged, off-by-default, snippet ready  
- [ ] Integrator: one green `just build` + `just build-cosmic`  
- [ ] `HYPRWAVE_EXECUTABLE_PLAN.md` marked superseded by this doc  

Product “working” (updated from old plan):

- Image builds, pins are reproducible, docs install path works  
- First login still functional (no regression from dormant features)  
- Assistant available after integrator hook (or clearly documented manual install)  
- Duress available only after deliberate enable  

---

## 10. Why this is faster than the serial executable plan

| Serial old plan | Parallel wave |
|---|---|
| Theme after stabilize after docs | Themes **already done** — skip |
| One person cycles contexts | Four specialists, no context switch |
| Features wait on “usable” | Usable code exists; A validates while C/D build features **dormant** |
| Docs wait on screenshots | Docs ship with TODOs; screenshots Wave 2 |
| Duress after everything | Duress parallel, never blocks ship |

Estimated calendar time if four models run at once:

- Wave 1 wall clock: **~2–4 days** (bounded by Assistant/Duress, not docs)  
- Serial equivalent: **~1.5–3 weeks**

---

*This document supersedes the sequencing in `HYPRWAVE_EXECUTABLE_PLAN.md` for execution. Keep the old file as historical intent; use this for multi-model dispatch.*
