#!/bin/bash
# Bazzite COSMIC - Gaming packages and system configuration
set -ouex pipefail

FEDORA_VERSION="${FEDORA_VERSION:-43}"

# ============================================================================
# REPOSITORIES
# ============================================================================

dnf5 -y install dnf5-plugins

# Enable Bazzite COPRs
for copr in \
    ublue-os/bazzite \
    ublue-os/bazzite-multilib \
    ublue-os/staging \
    ublue-os/obs-vkcapture; \
do
    dnf5 -y copr enable $copr
    dnf5 -y config-manager setopt "copr:copr.fedorainfracloud.org:${copr////:}".priority=98
done

# Add Terra repo (Mesa)
dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
    terra-release
dnf5 -y config-manager setopt "terra".enabled=true

# Add RPM Fusion
dnf5 -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${FEDORA_VERSION}.noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${FEDORA_VERSION}.noarch.rpm

# Add Negativo17 repos
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
mv /etc/yum.repos.d/fedora-multimedia.repo /etc/yum.repos.d/negativo17-fedora-multimedia.repo 2>/dev/null || true
dnf5 -y config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-steam.repo

# Set repo priorities
dnf5 -y config-manager setopt "*bazzite*".priority=1
dnf5 -y config-manager setopt "*terra*".priority=3 "*terra*".exclude="steam"
dnf5 -y config-manager setopt "*rpmfusion*".priority=5 "*rpmfusion*".exclude="mesa-*"

# ============================================================================
# PATCHED SYSTEM PACKAGES (Valve's versions from Bazzite)
# ============================================================================

# Swap to Bazzite's patched packages
dnf5 -y swap --repo=copr:copr.fedorainfracloud.org:ublue-os:bazzite wireplumber wireplumber || true
dnf5 -y swap --repo=copr:copr.fedorainfracloud.org:ublue-os:bazzite-multilib pipewire pipewire || true
dnf5 -y swap --repo=copr:copr.fedorainfracloud.org:ublue-os:bazzite-multilib bluez bluez || true
dnf5 -y swap --repo=copr:copr.fedorainfracloud.org:ublue-os:bazzite-multilib xorg-x11-server-Xwayland xorg-x11-server-Xwayland || true

# Lock patched packages
dnf5 versionlock add \
    pipewire pipewire-alsa pipewire-libs pipewire-pulseaudio \
    wireplumber wireplumber-libs \
    bluez bluez-libs \
    xorg-x11-server-Xwayland \
    mesa-dri-drivers mesa-filesystem mesa-libEGL mesa-libGL \
    mesa-libgbm mesa-va-drivers mesa-vulkan-drivers || true

# 32-bit Mesa
dnf5 -y install mesa-va-drivers.i686

# ============================================================================
# GAMING PACKAGES
# ============================================================================

# Core gaming
dnf5 -y install \
    steam \
    lutris \
    gamescope \
    gamescope-libs.x86_64 \
    gamescope-libs.i686 \
    gamescope-shaders \
    umu-launcher

# Overlays and capture
dnf5 -y install \
    mangohud.x86_64 \
    mangohud.i686 \
    vkBasalt.x86_64 \
    vkBasalt.i686 \
    libobs_vkcapture.x86_64 \
    libobs_vkcapture.i686 \
    libobs_glcapture.x86_64 \
    libobs_glcapture.i686

# Wine/Proton dependencies
dnf5 -y install \
    libFAudio.x86_64 \
    libFAudio.i686

# ROCm for AMD GPUs
dnf5 -y --setopt=install_weak_deps=False install \
    rocm-hip \
    rocm-opencl \
    rocm-clinfo \
    rocm-smi

# Media codecs
dnf5 -y install --enable-repo="*rpmfusion*" --disable-repo="*fedora-multimedia*" \
    libaacs \
    libbdplus \
    libbluray

# ============================================================================
# UTILITIES
# ============================================================================

dnf5 -y install \
    btop \
    fastfetch \
    fish \
    gnome-disk-utility \
    vulkan-tools \
    p7zip \
    p7zip-plugins \
    libxcrypt-compat

# Winetricks
curl -Lo /usr/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
chmod +x /usr/bin/winetricks

# ============================================================================
# SYSTEM CONFIGURATION
# ============================================================================

# Flathub
mkdir -p /etc/flatpak/remotes.d
curl --retry 3 -Lo /etc/flatpak/remotes.d/flathub.flatpakrepo https://dl.flathub.org/repo/flathub.flatpakrepo

# ============================================================================
# CLEANUP
# ============================================================================

# Disable repos at runtime
for copr in \
    ublue-os/bazzite \
    ublue-os/bazzite-multilib \
    ublue-os/staging \
    ublue-os/obs-vkcapture; \
do
    dnf5 -y copr disable $copr
done

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-steam.repo 2>/dev/null || true
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo 2>/dev/null || true
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/terra*.repo 2>/dev/null || true

dnf5 clean all
rm -rf /tmp/* /var/tmp/*

echo "Bazzite COSMIC build complete"
