# Theoretical COSMIC Customizations

**ALL CONTENT IN THIS DIRECTORY IS THEORETICAL PLANNING MATERIAL.**

**Nothing here may be merged, copied, or executed against the main tree without Claude handoff verification.**

See ../COSMIC-THEME-AND-STORE-REPLACEMENT.md and ../README.md for the full plan and process.

## Contents

- `hyprwave-theme/` — Example Hyprwave .ron theme + docs
- `configs/` — Hypothetical config fragments for new-user defaults (skel)

## Key Planned Behaviors

1. **Remove cosmic-store**
   - After `@cosmic-desktop-environment`, run `dnf5 remove -y cosmic-store`

2. **FlatArcade as the app store**
   - Leverage the already-installed shared `flatarcade` binary + .desktop
   - Make it discoverable and default in the COSMIC launcher/panel experience
   - Use skel + system config to bias toward it

3. **Hyprwave Theme**
   - Ship custom .ron using the canonical palette (#15052e, #ff2d95, #00f0ff, etc.)
   - Set as default for new users
   - Pair with Hyprwave wallpaper

## How These Would Be Integrated (described only)

See the main planning .md for the hypothetical snippets that would go into the `cosmic)` case of `build_files/build.sh`.

## Reminder
These files exist so we can iterate on design **without touching production code** during this planning session.
