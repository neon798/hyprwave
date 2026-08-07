#!/bin/bash
#
# Builds nuvious/pam-duress from a pinned commit and stages runtime artifacts
# into $DESTROOT (default /install) for COPY into the final bootc image.
#
# Intended to run in a dedicated builder stage (see
# planning/integration/d-duress/Containerfile.snippet) so gcc/pam-devel/
# openssl-devel never reach the final image — same pattern as build-hypr-utils.sh.
#
# OFF BY DEFAULT: this script only stages binaries. It does NOT edit /etc/pam.d.
# PAM enablement is a separate human step (ENABLE.md).

set -ouex pipefail

DESTROOT="${DESTROOT:-/install}"
JOBS="$(nproc)"

### Pin — update this SHA deliberately; do not track floating main.
### Source: https://github.com/nuvious/pam-duress
### Recorded tip of main as of 2026-07-16 (post-Sonar config merge).
PAM_DURESS_REPO="${PAM_DURESS_REPO:-https://github.com/nuvious/pam-duress.git}"
PAM_DURESS_COMMIT="${PAM_DURESS_COMMIT:-1f699c157fbafd03c48032661d5f15f87e8efd13}"

### Fedora / RH: PAM modules live under /usr/lib64/security (not /lib/security).
PAM_DIR_REL="${PAM_DIR_REL:-usr/lib64/security}"
BIN_DIR_REL="${BIN_DIR_REL:-usr/bin}"

echo "==> build-duress: repo=${PAM_DURESS_REPO} commit=${PAM_DURESS_COMMIT}"
echo "==> build-duress: DESTROOT=${DESTROOT} PAM_DIR_REL=${PAM_DIR_REL}"

### Build-time deps (throwaway stage only)
dnf5 install -y \
	gcc make git \
	pam-devel \
	openssl-devel \
	pkgconf-pkg-config

WORKDIR=/tmp/pam-duress-src
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

git init
git remote add origin "$PAM_DURESS_REPO"
git fetch --depth 1 origin "$PAM_DURESS_COMMIT"
git checkout --force FETCH_HEAD

echo "==> build-duress: checked out $(git rev-parse HEAD)"
test "$(git rev-parse HEAD)" = "$PAM_DURESS_COMMIT"

### Upstream Makefile: builds bin/pam_duress.so, bin/duress_sign, bin/pam_test
make -j"$JOBS"

### Stage into DESTROOT (do not install into the builder's live PAM path only)
mkdir -p \
	"$DESTROOT/$PAM_DIR_REL" \
	"$DESTROOT/$BIN_DIR_REL"

install -m0755 bin/pam_duress.so "$DESTROOT/$PAM_DIR_REL/pam_duress.so"
install -m0755 bin/duress_sign "$DESTROOT/$BIN_DIR_REL/duress_sign"
### pam_test is useful for disposable-VM validation; small binary, ship it.
install -m0755 bin/pam_test "$DESTROOT/$BIN_DIR_REL/pam_test"

### Runtime shared libs (libssl/libcrypto/libpam) come from the base image packages;
### ensure they exist when the integrator wires the final stage. openssl-libs + pam
### are already on ublue base-main.

### Manifest for debugging image contents
mkdir -p "$DESTROOT/usr/share/hyprwave/duress"
{
	echo "pam-duress commit=${PAM_DURESS_COMMIT}"
	echo "built=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
	echo "pam_duress.so -> /$PAM_DIR_REL/pam_duress.so"
	echo "duress_sign   -> /$BIN_DIR_REL/duress_sign"
	echo "pam_test      -> /$BIN_DIR_REL/pam_test"
} >"$DESTROOT/usr/share/hyprwave/duress/BUILD-INFO.txt"

echo "==> build-duress: staged tree:"
find "$DESTROOT" -type f | sort

echo "==> build-duress: OK"
