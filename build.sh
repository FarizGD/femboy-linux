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

cat "$ROOT/installer/packages.x86_64" >> "$PROFILE/packages.x86_64"
sort -u -o "$PROFILE/packages.x86_64" "$PROFILE/packages.x86_64"
cp -a "$ROOT/installer/airootfs/." "$PROFILE/airootfs/"

# Payload used by the installer to build the installed system.
install -Dm755 "$ROOT/bin/apt" "$PROFILE/airootfs/usr/bin/apt"
install -Dm755 "$ROOT/bin/apt" "$PROFILE/airootfs/usr/share/femboy-linux/apt"
install -Dm644 "$ROOT/installed-system/packages.x86_64" \
  "$PROFILE/airootfs/usr/share/femboy-linux/packages.x86_64"
install -Dm755 "$ROOT/installed-system/install-wallpapers.sh" \
  "$PROFILE/airootfs/usr/share/femboy-linux/install-wallpapers.sh"

mkdir -p "$PROFILE/airootfs/usr/share/femboy-linux/rootfs"
cp -a "$ROOT/installed-system/rootfs/." \
  "$PROFILE/airootfs/usr/share/femboy-linux/rootfs/"

if [[ -d "$ROOT/wallpapers" ]]; then
  mkdir -p "$PROFILE/airootfs/usr/share/femboy-linux/wallpapers"
  cp -a "$ROOT/wallpapers/." "$PROFILE/airootfs/usr/share/femboy-linux/wallpapers/"
fi

# Dedicated live installer account. An empty password lets SDDM accept the
# account by pressing Enter; this applies only to the disposable live ISO.
mkdir -p "$PROFILE/airootfs/home/installer"
cp -a "$PROFILE/airootfs/etc/skel/." "$PROFILE/airootfs/home/installer/"
grep -q '^installer:' "$PROFILE/airootfs/etc/passwd" || \
  echo 'installer:x:1000:1000:Femboy Linux Installer:/home/installer:/bin/bash' >> "$PROFILE/airootfs/etc/passwd"
grep -q '^installer:' "$PROFILE/airootfs/etc/group" || \
  echo 'installer:x:1000:' >> "$PROFILE/airootfs/etc/group"
grep -q '^installer:' "$PROFILE/airootfs/etc/shadow" || \
  echo 'installer::1::::::' >> "$PROFILE/airootfs/etc/shadow"
grep -q '^installer:' "$PROFILE/airootfs/etc/gshadow" || \
  echo 'installer:!::' >> "$PROFILE/airootfs/etc/gshadow"

sed -i 's/^iso_name=.*/iso_name="femboy-linux"/' "$PROFILE/profiledef.sh"
sed -i 's/^iso_label=.*/iso_label="FEMBOY_$(date +%Y%m)"/' "$PROFILE/profiledef.sh"
sed -i 's|^iso_publisher=.*|iso_publisher="Femboy Linux Project"|' "$PROFILE/profiledef.sh"
sed -i 's|^iso_application=.*|iso_application="Femboy Linux Installer"|' "$PROFILE/profiledef.sh"

# NetworkManager + KDE's SDDM display manager in the live environment.
mkdir -p "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants"
ln -sf /usr/lib/systemd/system/NetworkManager.service \
  "$PROFILE/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
mkdir -p "$PROFILE/airootfs/etc/systemd/system"
ln -sf /usr/lib/systemd/system/sddm.service \
  "$PROFILE/airootfs/etc/systemd/system/display-manager.service"
ln -sf /usr/lib/systemd/system/graphical.target \
  "$PROFILE/airootfs/etc/systemd/system/default.target"

cat >> "$PROFILE/profiledef.sh" <<'EOF'
file_permissions+=(
  ["/usr/local/bin/femboy-installer"]="0:0:0755"
  ["/usr/local/bin/femboy-install-backend"]="0:0:0755"
  ["/usr/local/bin/femboy-partitioner"]="0:0:0755"
  ["/usr/bin/apt"]="0:0:0755"
  ["/home/installer"]="1000:1000:0755"
  ["/home/installer/.bash_profile"]="1000:1000:0644"
  ["/etc/sudoers.d/10-installer"]="0:0:0440"
  ["/etc/xdg/autostart/femboy-installer.desktop"]="0:0:0644"
  ["/etc/sddm.conf.d/10-femboy.conf"]="0:0:0644"
)
EOF

mkarchiso -v -r -w "$WORK" -o "$OUT" "$PROFILE"

ISO="$(find "$OUT" -maxdepth 1 -type f -name '*.iso' | head -n1)"
sha256sum "$ISO" > "$ISO.sha256"
echo "Built: $ISO"
