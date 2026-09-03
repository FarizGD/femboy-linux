#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="$ROOT/.build/profile"
WORK="$ROOT/.build/work"
OUT="$ROOT/out"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo ./build.sh"
  exit 1
fi

command -v mkarchiso >/dev/null 2>&1 || {
  echo "archiso is not installed"
  exit 1
}

rm -rf "$ROOT/.build"
mkdir -p "$PROFILE" "$OUT"
rm -f "$OUT"/*.iso "$OUT"/*.sha256 2>/dev/null || true

cp -a /usr/share/archiso/configs/releng/. "$PROFILE/"

# Add our installer packages to the current releng package set.
cat "$ROOT/installer/packages.x86_64" >> "$PROFILE/packages.x86_64"
sort -u -o "$PROFILE/packages.x86_64" "$PROFILE/packages.x86_64"

# Overlay our installer filesystem.
cp -a "$ROOT/installer/airootfs/." "$PROFILE/airootfs/"

# Install Femboy Linux command wrappers into the ISO filesystem.
install -Dm755 "$ROOT/bin/apt" "$PROFILE/airootfs/usr/bin/apt"

# Rebrand the current releng profile without replacing its current boot config.
sed -i 's/^iso_name=.*/iso_name="femboy-linux"/' "$PROFILE/profiledef.sh"
sed -i 's/^iso_label=.*/iso_label="FEMBOY_$(date +%Y%m)"/' "$PROFILE/profiledef.sh"
sed -i 's|^iso_publisher=.*|iso_publisher="Femboy Linux Project"|' "$PROFILE/profiledef.sh"
sed -i 's|^iso_application=.*|iso_application="Femboy Linux Installer"|' "$PROFILE/profiledef.sh"

# Enable the services needed by the installer environment.
mkdir -p "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants"
mkdir -p "$PROFILE/airootfs/etc/systemd/system/graphical.target.wants"
ln -sf /usr/lib/systemd/system/NetworkManager.service \
  "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
ln -sf /usr/lib/systemd/system/femboy-installer.service \
  "$PROFILE/airootfs/etc/systemd/system/graphical.target.wants/femboy-installer.service"
ln -sf /usr/lib/systemd/system/graphical.target \
  "$PROFILE/airootfs/etc/systemd/system/default.target"

# Ensure custom executables are executable in the generated image.
cat >> "$PROFILE/profiledef.sh" <<'EOF'
file_permissions+=(
  ["/usr/local/bin/femboy-installer"]="0:0:0755"
  ["/usr/bin/apt"]="0:0:0755"
)
EOF

mkarchiso -v -r -w "$WORK" -o "$OUT" "$PROFILE"

ISO="$(find "$OUT" -maxdepth 1 -type f -name '*.iso' | head -n1)"
sha256sum "$ISO" > "$ISO.sha256"

echo "Built: $ISO"
