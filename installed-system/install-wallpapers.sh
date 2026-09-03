#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/wallpapers"
DEST="${DESTDIR:-}/usr/share/wallpapers/FemboyLinux"

install_wallpaper() {
  local name="$1"
  local file="$2"
  local size="$3"

  [[ -f "$SRC/$file" ]] || {
    echo "Missing wallpaper: $SRC/$file" >&2
    return 1
  }

  install -Dm644 "$SRC/$file" "$DEST/$name/contents/images/$size.webp"
}

install_wallpaper whale-girl whale-girl.webp 2048x1448
install_wallpaper arch-anime arch-anime.webp 2048x1152
install_wallpaper debian-anime debian-anime.webp 1920x1080
install_wallpaper night-rooftop night-rooftop.webp 2048x1152
