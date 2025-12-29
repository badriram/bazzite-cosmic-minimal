# Bazzite COSMIC - Gaming image based on Fedora COSMIC + Bazzite kernel
#
# Uses Fedora COSMIC as base, adds Bazzite's custom kernel and gaming stack

ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"
ARG ARCH="${ARCH:-x86_64}"
ARG BASE_IMAGE="quay.io/fedora-ostree-desktops/cosmic-atomic:${FEDORA_VERSION}"
ARG KERNEL_REF="ghcr.io/bazzite-org/kernel-bazzite:latest-f${FEDORA_VERSION}-${ARCH}"

# Pull Bazzite kernel
FROM ${KERNEL_REF} AS kernel

# Build context
FROM scratch AS ctx
COPY build_files /

# Main image
FROM ${BASE_IMAGE}

ARG FEDORA_VERSION="${FEDORA_VERSION:-43}"

# Install Bazzite kernel
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=bind,from=kernel,src=/,dst=/rpms/kernel \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/install-kernel.sh

# Install gaming packages and configure system
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=bind,from=ctx,source=/,target=/ctx \
    /ctx/build.sh

# Verify the image
RUN bootc container lint
