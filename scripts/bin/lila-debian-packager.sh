#!/bin/bash
# ═══════════════════════════════════════════════════════════════════
# Lila HD - Debian/Universal Packager - Terminal Version
# ═══════════════════════════════════════════════════════════════════

WORKDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$WORKDIR"
EXPORT_DIR="EXPORT_DEBIAN"
mkdir -p "$EXPORT_DIR"

echo -e "\e[34m[1/2]\e[0m Creazione pacchetto DEB..."
mkdir -p build-deb/usr/share/icons build-deb/DEBIAN
cp -a Lila_HD* build-deb/usr/share/icons/ [cite: 19]

# File Control
cat <<EOF > build-deb/DEBIAN/control
Package: lila-hd-icon-theme
Version: 3.3-2026
Section: gnome
Priority: optional
Architecture: all
Maintainer: ilnanny75
Depends: adwaita-icon-theme, hicolor-icon-theme
Description: Lila HD Icon Theme (2026 Edition)
 Professional SVG icon theme for Linux desktops.
EOF

# Script Post-Installazione (Cache)
cat <<EOF > build-deb/DEBIAN/postinst
#!/bin/bash
for dir in /usr/share/icons/Lila_HD*; do
    if [ -d "\$dir" ]; then
        gtk-update-icon-cache -f -t "\$dir" >/dev/null 2>&1 || true
    fi
done
EOF
chmod 755 build-deb/DEBIAN/postinst

dpkg-deb --build build-deb "$EXPORT_DIR/lila-hd-icon-theme-2026.deb" > /dev/null
rm -rf build-deb
echo -e "\e[32m✔ Pacchetto DEB pronto.\e[0m"

echo -e "\e[34m[2/2]\e[0m Creazione archivio universale TGZ..."
tar --exclude=".git*" -cvzf "$EXPORT_DIR/lila-hd-icon-theme-2026.tar.gz" Lila_HD* > /dev/null
echo -e "\e[32m✔ Archivio TGZ pronto.\e[0m"

echo -e "\n\e[1mProcesso completato! I file sono in: $EXPORT_DIR\e[0m"
