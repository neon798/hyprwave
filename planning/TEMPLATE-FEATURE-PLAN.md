# TEMPLATE: Feature Planning Document

**THIS IS A THEORETICAL PLANNING DOCUMENT ONLY.**

**DO NOT IMPLEMENT ANY CHANGES DESCRIBED HERE IN THE MAIN CODEBASE.**

Implementation requires **Claude handoff verification** (see planning/README.md).

## Feature Name
[Short slug, e.g. COSMIC-HYPRWAVE-THEME]

## Status
- [ ] Research complete
- [ ] Design drafted
- [ ] Theoretical files created
- [ ] Handoff checklist ready
- [ ] Awaiting Claude review + verification

## Problem Statement
[What is broken / missing, user report, current behavior]

## Goals / Acceptance Criteria
- Bullet list of what "done" looks like
- Must be testable in a VM (`just run-vm-qcow2-cosmic` or similar)

## Background / Research
- Links to searches, existing code, upstream docs
- Key facts about COSMIC (packages, config locations, theming format)

## Theoretical Design
### High-level Architecture
How this would integrate with the DE=cosmic path.

### Changes That Would Be Made (described only)
- In `build_files/build.sh` (cosmic case):
  ```bash
  # hypothetical
  ```
- New files that would be added to skel or /usr/share
- Config formats

### New / Modified Assets
- List hypothetical files under `planning/theoretical/`

## Example Files (Theoretical)
See `planning/theoretical/...` for sample content. These files are **not** part of any build and must not be copied into `build_files/` without verification.

## Risks & Open Questions
- List

## Handoff Checklist (for Claude)
- [ ] Review this document + all theoretical examples
- [ ] Verify against current main (post-GROK.md tasks)
- [ ] Confirm no behavior change for DE=hyprland
- [ ] Test plan: build cosmic, boot in VM, visual + functional checks
- [ ] Update CLAUDE.md / README.md if needed (surgically)
- [ ] Ensure `just lint`, `just check`, `bootc container lint` would still pass
- [ ] Sign off before any edit to main files

## References
- GROK.md tasks (T002-T010)
- Existing Hyprwave palette (see AGENTS.md, SDDM theme.conf, walker style.css)
- Upstream COSMIC docs / cosmic-themes.org

---

*Template version for consistent planning .md files.*
