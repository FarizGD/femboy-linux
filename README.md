# Femboy Linux

Femboy Linux is an Arch-based **installer ISO** project. The ISO is not intended to be a general-purpose live desktop; it boots into a lightweight graphical installer environment and installs a KDE Plasma system.

## What it installs

- Arch Linux base
- Linux kernel + firmware
- KDE Plasma 6
- SDDM
- NetworkManager
- PipeWire + WirePlumber
- Dolphin, Konsole, Kate, Ark, Spectacle, Firefox
- GRUB + efibootmgr

## Build locally

Run this on an Arch Linux machine:

```bash
sudo pacman -Syu --needed archiso git rsync
sudo ./build.sh
```

The ISO is written to `out/`.

## GitHub Actions

The workflow in `.github/workflows/build-iso.yml` builds the ISO in an Arch Linux container and uploads the resulting ISO plus SHA256 checksum as workflow artifacts.

You can trigger it manually from **Actions → Build Femboy Linux ISO → Run workflow**. Pushes that modify the build files also trigger a build.

## Project layout

```text
.
├── build.sh
├── installer/
│   ├── packages.x86_64
│   └── airootfs/
├── installed-system/
│   └── packages.x86_64
└── .github/workflows/build-iso.yml
```

The build uses the current Archiso `releng` profile installed on the build machine and overlays this repository's installer files on top, which avoids pinning old Archiso bootloader internals.
