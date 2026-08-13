# Global build arg selecting the desktop variant. Must be declared before the
# first FROM: only pre-FROM args are expandable in FROM lines (the de-${DE}
# selector at the bottom). DE=hyprland keeps full backward compat.
ARG DE=hyprland

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Hyprland utility ecosystem builder stage. Compiles hyprland-qtutils, hyprpaper,
# hyprpicker, hyprsunset (+ their hypr* libs) from source and stages them into
# /install. None of the heavy -devel toolchain reaches the final image; only the
# /install tree is COPYed in below. See build_files/build-hypr-utils.sh for why.
# This stage is Hyprland-only; the de-cosmic final stage never references it so
# podman/buildah skip it entirely when DE=cosmic (see de-${DE} pattern below).
FROM ghcr.io/ublue-os/base-main:latest AS hyprbuilder
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build-hypr-utils.sh

# Duress builder stage. Compiles nuvious/pam-duress (pam_duress.so + duress_sign)
# from a pinned commit and stages into /install. OFF BY DEFAULT: only binaries are
# staged; no /etc/pam.d edits happen here. PAM enablement is a human post-boot step.
FROM ghcr.io/ublue-os/base-main:latest AS duressbuilder
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build-duress.sh

# Hyprwave Assistant builder stage. Independent of hyprbuilder; usable for both
# the hyprland and cosmic variants. Builds a static Go binary (CGO_ENABLED=0).
# The heavy golang toolchain never reaches the final image.
FROM docker.io/library/golang:1.23-bookworm AS assistant-builder
WORKDIR /src
COPY apps/hyprwave-assistant/go.mod apps/hyprwave-assistant/go.sum ./
RUN go mod download
COPY apps/hyprwave-assistant/ ./
ARG ASSISTANT_VERSION=0.2.2
ENV CGO_ENABLED=0
RUN go test ./... \
 && go build -trimpath \
      -ldflags="-s -w -X main.version=${ASSISTANT_VERSION}" \
      -o /out/hyprwave-assistant .

# Global build arg (must be before any FROM that uses it in FROM).
# DE=hyprland keeps full backward compat and current behavior.
ARG DE=hyprland

# Base Image
FROM ghcr.io/ublue-os/base-main:latest AS base


## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

# Re-declare ARG so it is available inside this stage; pass DE through to build.sh
# so the case "$DE" dispatch inside can select packages/skel/services.
ARG DE
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    DE=${DE} /ctx/build.sh

# Duress runtime tooling (pam_duress.so, duress_sign) — shared by both variants.
# Templates/docs/empty /etc/duress.d are installed by build.sh (build.sh.snippet).
COPY --from=duressbuilder /install/ /
RUN ldconfig

### Hyprland utilities built from source in the hyprbuilder stage above
### Only the de-hyprland alias includes the COPY from the (possibly-skipped) builder.
FROM base AS de-hyprland
COPY --from=hyprbuilder /install/ /
RUN ldconfig

### COSMIC variant has no extra content from the hyprbuilder stage.
FROM base AS de-cosmic

### Variant selector: podman/buildah with --skip-unused-stages (default) will only
### execute the referenced final stage + its dependencies. DE=hyprland includes
### the hyprbuilder work; DE=cosmic does not.
FROM de-${DE}

### Hyprwave Assistant binary (data + desktop entry installed via build.sh snippet)
COPY --from=assistant-builder /out/hyprwave-assistant /usr/bin/hyprwave-assistant
RUN chmod 0755 /usr/bin/hyprwave-assistant

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
