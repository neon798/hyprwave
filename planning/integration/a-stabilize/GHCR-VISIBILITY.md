# GHCR visibility (operator only)

Anonymous install is **blocked** until a human makes **both** packages Public.
This lane does **not** flip org/repo settings.

**Do not claim GHCR is public.** Last probe (2026-08-13,
`scripts/ghcr-pull-test.sh --owner neon798`):

| Image | Anonymous | Expected until Public |
|-------|-----------|------------------------|
| `ghcr.io/neon798/hyprwave:latest` | **FAIL** `unauthorized` | 403 / unauthorized |
| `ghcr.io/neon798/hyprwave-cosmic:latest` | inspect OK | still **not** a dual pass |

`ghcr-pull-test.sh` exits **1** unless **both** images inspect/pull without creds.

CI already **pushed and signed** both variants (`77755f1`, Actions run
`31662742064`). Visibility is a package setting, not a missing push.

## Copy-paste: make packages Public

GitHub UI (package owner / org admin):

1. Open `https://github.com/neon798?tab=packages` (or org **Packages**).
2. Open package **`hyprwave`** → **Package settings** (gear / ⋯).
3. **Change visibility** → **Public** → confirm.
4. Repeat for package **`hyprwave-cosmic`**.
5. Leave **Inherit access from repository** as your threat model allows.

CLI check after the clicks (no `podman login`, empty auth):

```bash
# Expect exit 1 and unauthorized on hyprwave until both packages are Public.
bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh --owner neon798

# After both are Public this must be exit 0:
bash planning/integration/a-stabilize/scripts/ghcr-pull-test.sh --owner neon798
echo exit:$?

# Then signatures (needs anonymous pull):
cosign verify --key cosign.pub ghcr.io/neon798/hyprwave:latest
cosign verify --key cosign.pub ghcr.io/neon798/hyprwave-cosmic:latest
```

Prefer a **dated tag** or **digest** for install targets (`RELEASE.md`); do not
document floating `:latest` as the only public pin.

## If packages stay private

Do **not** tell users they can `podman pull` anonymously. Use the private
contingency in `RELEASE.md` (PAT `read:packages` + login + dated tag/digest).

## Related

- `RELEASE.md` — publish path + private contingency
- `COSIGN.md` — verify blocked on unauthorized hyprland
- `scripts/ghcr-pull-test.sh` — fail-closed dual probe
