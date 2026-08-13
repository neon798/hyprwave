# Parallel Wave 2 — Overnight (4 independent models)

**Status:** Ready to dispatch  
**Date:** 2026-08-06  
**Goal:** Deepen each Wave 1 deliverable overnight with **zero cross-lane waiting** and **zero shared-file edits**.  
**Morning job (human/integrator):** merge Wave 1+2 lanes in order A → B → C → D, apply remaining snippets, dual-variant build.

---

## Wave 1 status (pushed)

| Lane | Branch (origin) | Tip | Deliverable |
|---|---|---|---|
| A | `lane/a-stabilize` | pin Yazi/Neonwolf/FlatArcade + checklists | `versions.env`, pinned `build.sh` |
| B | `lane/b-docs` | INSTALL / CHANGELOG / keybinds | discoverability |
| C | `lane/c-assistant` | Go Bubble Tea assistant (dormant) | `apps/hyprwave-assistant/` + data + snippets |
| D | `lane/d-duress` | pam-duress packaging (OFF) | `build_files/duress/` + snippets |

Base of all Wave 1 work: `main` @ `8a623a2`.  
**Wave 2 does not wait for a merge to main.** Each model continues on **its own Wave 1 branch**.

---

## Hard rules (overnight)

1. **Base branch = your Wave 1 tip** (not `main`, not another lane).
2. **Exclusive paths only** (matrix below). If you need another path → write `planning/integration/<lane>/HANDOFF-WAVE2.md`, do not edit.
3. **Never edit** during Wave 2:
   - other lanes’ trees
   - live `/etc/pam.d` enablement for duress (still human-only)
   - another model’s `build.sh` ownership (A already owns pins in `build.sh`; C/D only improve **snippets**)
4. **Commit often, push your lane branch** before sleep / when done:
   ```bash
   git push -u origin HEAD
   ```
5. **No full image build required** overnight unless you have spare machine time. Prefer unit tests, `bash -n`, `go test`, lint.
6. **Do not open PRs into each other.** Morning integrator merges.

---

## Ownership matrix (Wave 2)

| Path | A | B | C | D |
|---|---|---|---|---|
| `build_files/versions.env` | **own** | — | — | — |
| `build_files/build.sh` | **own** (pins/CI only; no feature hooks for C/D) | — | — | — |
| `.github/workflows/*` | **own** | — | — | — |
| `planning/integration/a-stabilize/**` | **own** | — | — | — |
| `INSTALL.md` `CHANGELOG.md` `docs/**` `README.md` | — | **own** | blurbs → integration only | blurbs → integration only |
| `planning/integration/b-docs/**` | — | **own** | — | — |
| `apps/hyprwave-assistant/**` | — | — | **own** | — |
| `build_files/usr/share/hyprwave/assistant/**` | — | — | **own** | — |
| `build_files/usr/share/applications/hyprwave-assistant.desktop` | — | — | **own** | — |
| `planning/integration/c-assistant/**` | — | — | **own** | — |
| `build_files/duress/**` `build_files/build-duress.sh` | — | — | — | **own** |
| `planning/integration/d-duress/**` | — | — | — | **own** |
| `build_files/etc/skel/**` | — | — | **snippet only** (no skel edit) | — |
| `Containerfile` `Justfile` | snippet/notes only | — | snippet only | snippet only |

**Skel stays frozen overnight.** Keybinds for assistant = HANDOFF note only.

---

## MODEL A — Stabilize deep / CI & release readiness

**Branch:** `lane/a-stabilize` (continue)  
**Mission:** Make pins and CI trustworthy so morning merge is shippable.

### Do

1. **Pin hygiene**
   - Ensure `build_files/versions.env` is the single source of truth; `build.sh` sources it.
   - Add optional sha256 verification if not already present (fail build on mismatch).
   - `planning/integration/a-stabilize/BUMP.md` stays accurate.

2. **CI guards** (edit workflows only on this branch)
   - Job or step: `grep -R 'releases/latest' build_files/build.sh` must fail if found.
   - Job: `bash -n` on all `build_files/*.sh` (and duress when present — if not on branch, only what exists).
   - Do **not** redesign the whole matrix; surgical checks only.

3. **Release / publish notes**
   - `planning/integration/a-stabilize/RELEASE.md`: tag scheme, GHCR public visibility fix (Wave 1 noted private/403), cosign reminder.
   - Expand `FIRST-BOOT-CHECKLIST.md` with pass/fail log template.

4. **Automation (optional, nice overnight)**
   - `planning/integration/a-stabilize/scripts/verify-pins.sh` — curl -I versioned URLs, print status codes.
   - Document NVIDIA/hardware as out-of-scope checklist items only.

### Forbidden

- Implementing Assistant/Duress hooks in `build.sh`.
- README marketing rewrites (B owns docs).
- Waiting for other lanes.

### Done when

- [ ] At least one new commit on `lane/a-stabilize` for Wave 2 work  
- [ ] CI pin-guard or verify script exists  
- [ ] RELEASE.md + checklist updates committed  
- [ ] Branch pushed to origin  

### Validate

```bash
just lint || true
just check || true
bash planning/integration/a-stabilize/scripts/verify-pins.sh || true
grep -n 'releases/latest' build_files/build.sh && exit 1 || echo OK
```

---

## MODEL B — Docs depth / onboarding overnight

**Branch:** `lane/b-docs` (continue)  
**Mission:** Someone can install, troubleshoot, and understand the distro without reading planning/.

### Do

1. **Expand docs tree**
   - `docs/troubleshooting.md` — black screen, no wallpaper, Walker empty, bootc switch fails, NVIDIA pointer, GHCR auth.
   - `docs/architecture.md` — bootc, skel caveat, theme store, two DE variants (short).
   - `docs/updating.md` — `bootc upgrade`, reboot, Flatpak updates, pin philosophy (link, don’t copy A’s env file).
   - `docs/security.md` — high-level: immutable core, duress “optional / off by default” pointer (no enable steps copy-paste that imply it’s on).

2. **INSTALL.md polish**
   - Dual path: existing Atomic rebase vs ISO.
   - Explicit “image may be private until GHCR visibility fixed”.
   - Post-install: themes GUI, FlatArcade, Neonwolf.

3. **CHANGELOG**
   - Keep Unreleased accurate; note Wave 1 features as pending merge if not on main yet.

4. **Discoverability**
   - `docs/README.md` index linking all docs.
   - Screenshot checklist progress: mark which shots are still TODO; add alt-text descriptions for future captures.
   - Optional: short `docs/cosmic.md` differences.

5. **Integration blurbs**
   - `planning/integration/b-docs/README-sections.md` updated for Assistant + Duress *as optional upcoming* (not claiming shipped on main until merge).

### Forbidden

- Any `build_files/` code changes.
- Enabling or soft-enabling duress in prose as default.
- Blocking on real screenshots/VM.

### Done when

- [ ] troubleshooting + architecture + docs index committed  
- [ ] INSTALL/CHANGELOG updated  
- [ ] Branch pushed  

### Validate

- Links between docs resolve (relative paths exist).
- No Wofi/swaybg/Thunar-as-default language.

---

## MODEL C — Assistant productization overnight

**Branch:** `lane/c-assistant` (continue)  
**Mission:** Make the TUI feel production-ready and safer; keep image integration dormant via snippets.

### Do

1. **CLI surface**
   - `hyprwave-assistant update|install|kb|version` (or subcommands already stubbed — flesh out).
   - Non-interactive flags where safe: `--check`, `--dry-run` for flatpak/bootc paths.

2. **Updater / Installer robustness**
   - Clear errors if not root / no polkit / offline.
   - Capture command output with timeouts; never force reboot.
   - Confirm prompts for destructive actions.

3. **KB + catalog**
   - Expand articles: first-boot, Walker, themes, COSMIC vs Hyprland, FlatArcade.
   - Grow `catalog.toml` with verified Flathub IDs only (no invented app ids).
   - Duress KB stays “optional, off by default, see ENABLE.md after merge”.

4. **UX / theme**
   - Synthwave palette polish; optional read of `~/.config/hyprwave/theme` or env for accent (best-effort, no hard dep).
   - Empty states, search in KB, keybind help footer.

5. **Tests**
   - More `go test` for catalog parse, kb search, dry-run command builders.
   - `go test ./...` and `go build` must pass.

6. **Snippets only for image**
   - Improve `planning/integration/c-assistant/build.sh.snippet` + `Containerfile.snippet` (static binary, `-ldflags`, data path).
   - `HANDOFF-WAVE2.md`: suggested Super+Shift+A → `ghostty -e hyprwave-assistant` (integrator applies to skel).

### Forbidden

- Editing `build_files/etc/skel/**`.
- Editing production `build.sh` / `Containerfile` (snippets only).
- Duress/PAM code.
- Waiting on A’s pins.

### Done when

- [ ] `go test ./...` green  
- [ ] Meaningful feature commits beyond Wave 1 skeleton  
- [ ] Snippets + HANDOFF-WAVE2 updated  
- [ ] Branch pushed  

### Validate

```bash
cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .
```

---

## MODEL D — Duress hardening overnight (still OFF by default)

**Branch:** `lane/d-duress` (continue)  
**Mission:** Safer packaging, better setup UX, stronger docs; **never** enable PAM by default.

### Do

1. **Templates**
   - Keep wipe template; add **milder** opt-in template e.g. `10-clear-histories.sh` (shell history/clipboard only) — still unsigned.
   - Document which template is “aggressive” vs “mild” in README.

2. **Setup tool**
   - `--dry-run` (show actions, no sign).
   - Better validation of script modes before/after sign.
   - Refuse to sign if duress password equals a trivial list (optional weak check) or empty.
   - `--status` machine-readable optional (`--json` nice-to-have).

3. **Build script**
   - Confirm pin SHA still correct; add comment how to bump.
   - If easy: verify `sha256sum` of downloaded archive when switching from git commit pin (optional).
   - Keep DESTROOT staging; no live PAM install side effects.

4. **Snippets**
   - Refine `build.sh.snippet` / `Containerfile.snippet`.
   - Optional build-arg documentation: `DURESS=assets` (default) vs never `DURESS=enable` in CI.
   - Expand ENABLE.md with Fedora Atomic specifics and “keep root shell open” checklist.

5. **Safety tests**
   - `bash -n` all scripts in CI-oriented `planning/integration/d-duress/validate.sh`.
   - Assert stock packaging paths never contain `*.sha256` signed secrets in-tree.
   - Grep guard: no file under `build_files/duress` should rewrite `/etc/pam.d` at build time.

### Forbidden

- Enabling pam_duress in any shipped default config.
- Pre-signed `.sha256` files in the repo.
- Skel / assistant / docs tree (except integration ENABLE docs you already own).
- Weakening auth (always fail closed if misconfigured — document, don’t ship broken stacks).

### Done when

- [ ] Extra template + setup improvements committed  
- [ ] `validate.sh` or equivalent exists and passes  
- [ ] ENABLE.md / README still scream OFF BY DEFAULT  
- [ ] Branch pushed  

### Validate

```bash
bash -n build_files/build-duress.sh
bash -n build_files/duress/hyprwave-duress-setup
bash -n build_files/duress/templates/*.sh
bash planning/integration/d-duress/validate.sh
# must find no pam.d rewrites in build snippets:
grep -n 'pam.d' planning/integration/d-duress/build.sh.snippet || true
```

---

## Morning integrator (after overnight — not a fifth overnight model)

**Order:**

1. Create `integrate/wave1-wave2` from `main`.
2. Merge `lane/a-stabilize` (pins + any CI).
3. Merge `lane/b-docs`.
4. Merge `lane/c-assistant`; apply C snippets into `Containerfile` + `build.sh`.
5. Merge `lane/d-duress`; apply D snippets (**assets only**).
6. Resolve conflicts favoring A’s `build.sh` pin structure; append C/D hooks after pins.
7. `just lint && just check && just build && just build-cosmic`.
8. Open single PR to `main` (or push if policy allows).
9. **Do not** enable duress PAM in that PR unless explicitly requested.

---

## Copy-paste overnight commands

Run each in its own terminal / agent session. All can start **now**.

### Model A

```bash
cd /home/zen/hyprwave && git fetch origin && \
git worktree add /home/zen/hyprwave-lane-a-w2 lane/a-stabilize 2>/dev/null || true
cd /home/zen/hyprwave-lane-a-w2 2>/dev/null || { git checkout lane/a-stabilize; cd /home/zen/hyprwave; }
git pull origin lane/a-stabilize || true
cat <<'PROMPT'
You are MODEL A Wave 2 (overnight) for Hyprwave.
Branch: lane/a-stabilize (continue; base is your Wave 1 tip, NOT main).
Read: planning/PARALLEL-WAVE2-OVERNIGHT.md § MODEL A.

Mission: CI pin guards, verify-pins script, RELEASE.md, expand FIRST-BOOT-CHECKLIST.
Own: versions.env, build.sh pins only, .github/workflows, planning/integration/a-stabilize/.
Forbidden: assistant, duress, README rewrites, waiting on others.
Commit often; end with: git push -u origin lane/a-stabilize
PROMPT
```

### Model B

```bash
cd /home/zen/hyprwave && git fetch origin && \
git worktree add /home/zen/hyprwave-lane-b-w2 lane/b-docs 2>/dev/null || true
cd /home/zen/hyprwave-b-docs 2>/dev/null || cd /home/zen/hyprwave-lane-b-w2 2>/dev/null || git checkout lane/b-docs
git pull origin lane/b-docs || true
cat <<'PROMPT'
You are MODEL B Wave 2 (overnight) for Hyprwave.
Branch: lane/b-docs (continue).
Read: planning/PARALLEL-WAVE2-OVERNIGHT.md § MODEL B.

Mission: docs/troubleshooting.md, architecture.md, updating.md, security.md, docs/README.md index;
polish INSTALL.md + CHANGELOG; screenshot checklist progress.
Own: INSTALL.md, CHANGELOG.md, docs/**, README.md, planning/integration/b-docs/.
Forbidden: build_files/**, workflows, implementing features.
Commit often; end with: git push -u origin lane/b-docs
PROMPT
```

### Model C

```bash
cd /home/zen/hyprwave && git fetch origin && \
git checkout lane/c-assistant && git pull origin lane/c-assistant || true
cat <<'PROMPT'
You are MODEL C Wave 2 (overnight) for Hyprwave.
Branch: lane/c-assistant (continue).
Read: planning/PARALLEL-WAVE2-OVERNIGHT.md § MODEL C + planning/HYPRWAVE-ASSISTANT.md.

Mission: productionize hyprwave-assistant — CLI subcommands, dry-run, robust updater/installer,
more KB/catalog, tests; improve integration snippets only; HANDOFF-WAVE2 for Super+Shift+A.
Own: apps/hyprwave-assistant/**, build_files/usr/share/hyprwave/assistant/**, assistant .desktop, planning/integration/c-assistant/.
Forbidden: skel edits, build.sh/Containerfile (snippets only), duress, waiting on A/B/D.
Validate: cd apps/hyprwave-assistant && go test ./... && go build -o /tmp/hyprwave-assistant .
Commit often; end with: git push -u origin lane/c-assistant
PROMPT
```

### Model D

```bash
cd /home/zen/hyprwave-lane-d && git fetch origin && git checkout lane/d-duress && git pull origin lane/d-duress || true
cat <<'PROMPT'
You are MODEL D Wave 2 (overnight) for Hyprwave.
Branch: lane/d-duress (continue).
Read: planning/PARALLEL-WAVE2-OVERNIGHT.md § MODEL D + build_files/duress/README.md.

Mission: harden duress packaging STILL OFF BY DEFAULT — milder template, setup --dry-run,
validate.sh, snippet/ENABLE polish. No PAM enable. No pre-signed scripts.
Own: build_files/duress/**, build_files/build-duress.sh, planning/integration/d-duress/.
Forbidden: enabling pam_duress by default, skel, assistant, README product docs (B owns).
Validate: bash -n on all scripts; planning/integration/d-duress/validate.sh
Commit often; end with: git push -u origin lane/d-duress
PROMPT
```

---

## Definition of done (Wave 2)

Overnight success = all four branches have **new Wave 2 commits pushed** and each self-validate command is green.  
Product success waits until morning merge + dual build — not required overnight.

---

*Supersedes Wave 1 sequencing in `PARALLEL-4-MODEL-PLAN.md` for the next parallel cycle. Wave 1 plan remains historical for Gate 0 / ownership principles.*
