#!/usr/bin/bash
# Install Bazzite kernel from pre-built RPMs
# Based on Bazzite's install-kernel script

set -eoux pipefail

# Create shims to bypass kernel install triggering dracut/rpm-ostree
pushd /usr/lib/kernel/install.d
mv 05-rpmostree.install 05-rpmostree.install.bak
mv 50-dracut.install 50-dracut.install.bak
printf '%s\n' '#!/bin/sh' 'exit 0' > 05-rpmostree.install
printf '%s\n' '#!/bin/sh' 'exit 0' > 50-dracut.install
chmod +x 05-rpmostree.install 50-dracut.install
popd

# Remove Fedora kernel
dnf5 -y remove --no-autoremove \
    kernel \
    kernel-core \
    kernel-modules \
    kernel-modules-core \
    kernel-modules-extra \
    kernel-tools \
    kernel-tools-libs

# Bazzite kernel packages
pkgs=(
    kernel
    kernel-core
    kernel-modules
    kernel-modules-core
    kernel-modules-extra
    kernel-modules-akmods
    kernel-devel
    kernel-devel-matched
    kernel-tools
    kernel-tools-libs
    kernel-common
)

# Build install paths (kernel version starts with 6)
PKG_PAT=()
for pkg in "${pkgs[@]}"; do
    PKG_PAT+=("/rpms/kernel/${pkg}-6"*)
done

# Install Bazzite kernel
dnf5 -y install ${PKG_PAT[@]}

# Lock kernel version
dnf5 versionlock add ${pkgs[@]}

# Restore original install scripts
pushd /usr/lib/kernel/install.d
mv -f 05-rpmostree.install.bak 05-rpmostree.install
mv -f 50-dracut.install.bak 50-dracut.install
popd

# Get installed kernel version
KERNEL_VERSION=$(rpm -q kernel --qf '%{VERSION}-%{RELEASE}.%{ARCH}')
echo "Installed kernel: $KERNEL_VERSION"

# Regenerate initramfs for the new kernel
echo "Regenerating initramfs..."
dracut --force --kver "$KERNEL_VERSION"

echo "Bazzite kernel installed successfully"
