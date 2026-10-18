#!/bin/bash
# Repackages an RPCS3 AppImage into a .deb (unofficial, not affiliated with RPCS3)
# Usage: ./make-rpcs3-deb.sh path/to/rpcs3-*.AppImage [version]
set -euo pipefail

APPIMAGE="${1:?Usage: $0 path/to/rpcs3.AppImage [version]}"
VERSION="${2:-0.0.1}"
ARCH="${ARCH:-amd64}"                      # use arm64 for the ARM build
MAINTAINER="${MAINTAINER:-Jaimston <jaimstononeil9@gmail.com>}"

APPIMAGE="$(realpath "$APPIMAGE")"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
OUT="$PWD/rpcs3_${VERSION}_${ARCH}.deb"
PKG="$WORK/rpcs3-deb"

# Extract the AppImage
cp "$APPIMAGE" "$WORK/rpcs3.AppImage"
chmod +x "$WORK/rpcs3.AppImage"
(cd "$WORK" && ./rpcs3.AppImage --appimage-extract >/dev/null)

# Build package tree
mkdir -p "$PKG/DEBIAN" "$PKG/opt/rpcs3" "$PKG/usr/bin" \
         "$PKG/usr/share/applications" "$PKG/usr/share/icons"
cp -a "$WORK/squashfs-root/." "$PKG/opt/rpcs3/"

# Launcher wrapper (a symlink breaks AppRun's relative paths)
cat > "$PKG/usr/bin/rpcs3" <<'EOF'
#!/bin/sh
exec /opt/rpcs3/AppRun "$@"
EOF
chmod +x "$PKG/usr/bin/rpcs3"

# Icons
if [ -d "$WORK/squashfs-root/usr/share/icons" ]; then
    cp -a "$WORK/squashfs-root/usr/share/icons/." "$PKG/usr/share/icons/"
fi

# Desktop entry (check both the root and usr/share/applications)
DESKTOP="$(find "$WORK/squashfs-root" -maxdepth 4 -name '*.desktop' | head -n1 || true)"
if [ -n "$DESKTOP" ]; then
    cp "$DESKTOP" "$PKG/usr/share/applications/rpcs3.desktop"
    sed -i 's|^Exec=.*|Exec=rpcs3|' "$PKG/usr/share/applications/rpcs3.desktop"
else
    echo "Warning: no .desktop file found, menu entry will be missing"
fi

# Control file
cat > "$PKG/DEBIAN/control" <<EOF
Package: rpcs3
Version: $VERSION
Section: games
Priority: optional
Architecture: $ARCH
Maintainer: $MAINTAINER
Description: RPCS3 PlayStation 3 emulator (unofficial repackaged AppImage)
EOF

# Post-install: refresh desktop and icon caches
cat > "$PKG/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
update-desktop-database /usr/share/applications 2>/dev/null || true
gtk-update-icon-cache -f /usr/share/icons/hicolor 2>/dev/null || true
exit 0
EOF
chmod 755 "$PKG/DEBIAN/postinst"

dpkg-deb --build --root-owner-group "$PKG" "$OUT"

echo "Built: $OUT"
echo "Install with: sudo apt install $OUT"
