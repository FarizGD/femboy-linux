# Femboy Linux Wallpapers

Wallpapers bundled with Femboy Linux and available from KDE Plasma's wallpaper picker.

## Included wallpapers

| Wallpaper | File | Role |
| --- | --- | --- |
| Night Rooftop | `night-rooftop.webp` | **Default KDE Plasma wallpaper** |
| Whale Girl | `whale-girl.webp` | Alternative wallpaper |
| Arch Anime | `arch-anime.webp` | Alternative wallpaper |
| Debian Anime | `debian-anime.webp` | Alternative wallpaper |

## Default

`night-rooftop.webp` is the default wallpaper used by the Femboy Linux Plasma look-and-feel package.

The default is configured as:

```ini
[Wallpaper]
Image=FemboyLinux/night-rooftop
```

## Installation layout

During installation, these assets are packaged for KDE under:

```text
/usr/share/wallpapers/FemboyLinux/<name>/contents/images/
```

The source images in this directory should keep their current filenames because the distro build and wallpaper installation scripts reference them directly.

## Adding another wallpaper

1. Add the image to this directory, preferably as WebP.
2. Add it to `installed-system/install-wallpapers.sh` with its native resolution.
3. If it should become the default, update the Femboy Linux Plasma look-and-feel `contents/defaults` file.

Please keep wallpapers reasonably compressed so they do not unnecessarily increase the installer ISO size.
