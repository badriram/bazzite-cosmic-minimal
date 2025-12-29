# Bazzite COSMIC

A gaming-focused image combining [Fedora COSMIC Atomic](https://fedoraproject.org/cosmic/) with [Bazzite](https://bazzite.gg/)'s gaming optimizations.

## What's Included

**From Bazzite:**
- Custom kernel (fsync, HDR patches, gaming optimizations)
- Valve's patched Mesa, Pipewire, Bluez, Xwayland
- Steam, Lutris, Gamescope, umu-launcher
- MangoHud, vkBasalt, OBS VkCapture
- ROCm for AMD GPUs

**From Fedora COSMIC:**
- COSMIC desktop environment
- Clean Fedora base (no KDE/GNOME cruft)

## Building

```bash
# Build locally
just build

# Or with podman directly
podman build -t bazzite-cosmic:43 .
```

## Installation

```bash
# From local build
rpm-ostree rebase ostree-unverified-image:containers-storage:localhost/bazzite-cosmic:43

# From GitHub Container Registry (after CI builds)
rpm-ostree rebase ostree-unverified-image:docker://ghcr.io/YOUR_USERNAME/bazzite-cosmic:latest
```

## Rollback

```bash
rpm-ostree rollback
```

## What's NOT Included

This is a streamlined image. It does NOT include:
- ujust commands (Bazzite's CLI utilities)
- Steam Deck / Handheld support (hhd, gamescope-session)
- Waydroid, Sunshine, Cockpit
- Greenboot health checks
- Bazzite's system configuration scripts

For full Bazzite features on COSMIC, use a full Bazzite fork instead.

## License

MIT
