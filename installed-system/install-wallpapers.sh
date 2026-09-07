#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/wallpapers"
DEST="${DESTDIR:-}/usr/share/wallpapers/FemboyLinux"

install_wallpaper() {
  local name="$1"
  local title="$2"
  local file="$3"
  local size="$4"
  local dir="$DEST/$name"

  [[ -f "$SRC/$file" ]] || {
    echo "Missing wallpaper: $SRC/$file" >&2
    return 1
  }

  # Plasma discovers packaged wallpapers through metadata.json. Merely putting
  # an image under contents/images is not enough for it to appear in Settings.
  install -Dm644 "$SRC/$file" "$dir/contents/images/$size.webp"

  mkdir -p "$dir"
  cat > "$dir/metadata.json" <<EOF
{
  "KPlugin": {
    "Id": "org.femboylinux.wallpaper.$name",
    "Name": "$title",
    "Description": "Femboy Linux wallpaper",
    "Version": "1.0",
    "License": "CC0-1.0"
  },
  "KPackageStructure": "Plasma/Wallpaper"
}
EOF
  chmod 644 "$dir/metadata.json"
}

install_wallpaper whale-girl "Whale Girl" whale-girl.webp 2048x1448
install_wallpaper arch-anime "Arch Anime" arch-anime.webp 2048x1152
install_wallpaper debian-anime "Debian Anime" debian-anime.webp 1920x1080
install_wallpaper night-rooftop "Night Rooftop" night-rooftop.webp 2048x1152
