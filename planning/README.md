# Planning & Theoretical Feature Documentation

**Status: THEORY AND PLANNING MODE ONLY**

This directory exists for **reference, design, and handoff** only.

## Rules (strictly followed)

1. **No changes to main implementation** (`build.sh`, `Containerfile`, `Justfile`, `disk_config/`, `build_files/etc/skel/`, workflows, etc.) may be made from planning docs.
2. All work here is **theoretical**.
3. Implementation of any item here into the main tree **requires explicit Claude handoff verification**.
   - Claude (strong model) must review, approve the plan, and perform or sign off on the actual edits.
   - Grok (this session) is operating in evening planning mode while Claude quota is reserved.
4. Every planning doc must be clearly labeled as theoretical.
5. Use this structure for future features:
   - `planning/FEATURE-NAME.md`
   - Supporting examples in `planning/theoretical/...` (never referenced by build system)
   - Clear "Handoff Checklist" section
6. After Claude verification, the planning doc may be archived or referenced in commit messages.

## Current Focus (as of this document)

- COSMIC variant post-launch issues reported by user:
  - Theme did not carry over (default COSMIC theme pack is active).
  - Need to remove the built-in COSMIC Store.
  - Make FlatArcade the default "app store".
  - Create and ship a proper Hyprwave themepack using the official Hyprwave color palette as the primary/default theme.

See `COSMIC-THEME-AND-STORE-REPLACEMENT.md` for the detailed theoretical plan.

- Duress password feature (new)
  - Full planning document: `DURESS-PASSWORD.md`
  - Theoretical files in `planning/theoretical/duress/`
  - Supports both SDDM (Hyprland) and cosmic-greeter (COSMIC) via PAM Duress module.
  - Default action: secure wipe of sensitive user data on duress login/unlock.
  - User setup tool provided.

See `DURESS-PASSWORD.md` for the complete plan, risks, and handoff checklist.

- Hyprwave Assistant (new)
  - Full planning document: `HYPRWAVE-ASSISTANT.md`
  - Expanded from previous TUI updater/installer into a central assistant
  - Name: Hyprwave Assistant (`hyprwave-assistant`)
  - Sections: Updater + One-Click Installer + Need-to-Know Knowledge Base for the distro
  - Includes all previous catalog items + KB articles on philosophy, updates, theming, duress, keybinds, troubleshooting, variants, etc.
  - Go + Bubble Tea (user decision 2026-07-07; supersedes earlier Rust+ratatui notes), themable, pre-installed

See `HYPRWAVE-ASSISTANT.md` for the complete plan and handoff checklist.

## How to Add a New .md Planning Document

1. Create `planning/NEW-FEATURE-SLUG.md`
2. Use the template in `planning/TEMPLATE-FEATURE-PLAN.md` (create if missing).
3. Populate sections: Problem, Goals, Research, Theoretical Design, Handoff Checklist, Risks.
4. Add any example files under `planning/theoretical/` with heavy "DO NOT USE IN MAIN" headers.
5. Update this README with a short link/entry.
6. Do **not** edit production files.

This process ensures clean separation between planning (Grok) and verified implementation (Claude handoff).

---

*Generated during theory/planning session. All content below this line in sub-documents is for reference only.*
