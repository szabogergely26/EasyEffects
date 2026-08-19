#!/bin/bash

set -e
# Mindig a projekt gyökeréből dolgozunk, akkor is,
# ha a scriptet a packaging/deb mappából indítjuk.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

# Név, verzió:
# A verziószám egyetlen forrásból, a plasmoid metadata.json KPlugin.Version
# mezőjéből származik - máshova (control, ez a script) ne kerüljön kézzel
# beírt verziószám, mindig innen töltődik be.
PACKAGE_NAME="easyeffects-quickaccess"
PLASMOID_ID="org.kde.easyeffectsquick"
VERSION="$(python3 -c "import json; print(json.load(open('${PLASMOID_ID}/metadata.json'))['KPlugin']['Version'])")"
BUILD_DIR="build/${PACKAGE_NAME}_${VERSION}_all"
OUTPUT_DIR="dist"

rm -rf build
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$OUTPUT_DIR"

cp packaging/deb/control "$BUILD_DIR/DEBIAN/control"
sed -i "s/@VERSION@/${VERSION}/" "$BUILD_DIR/DEBIAN/control"
cp packaging/deb/postinst "$BUILD_DIR/DEBIAN/postinst"
cp packaging/deb/prerm "$BUILD_DIR/DEBIAN/prerm"

# A plasmoid fájljai a rendszerszintű Plasma widget-könyvtárba kerülnek
mkdir -p "$BUILD_DIR/usr/share/plasma/plasmoids/${PLASMOID_ID}"
cp -a "${PLASMOID_ID}/." "$BUILD_DIR/usr/share/plasma/plasmoids/${PLASMOID_ID}/"

find "$BUILD_DIR" -type d -exec chmod 755 {} \;

# jogosultság beállítása
chmod 755 "$BUILD_DIR/DEBIAN/postinst"
chmod 755 "$BUILD_DIR/DEBIAN/prerm"
find "$BUILD_DIR/usr/share/plasma/plasmoids/${PLASMOID_ID}" -type f -exec chmod 644 {} \;
find "$BUILD_DIR/usr/share/plasma/plasmoids/${PLASMOID_ID}" -type d -exec chmod 755 {} \;

dpkg-deb --root-owner-group --build "$BUILD_DIR" "$OUTPUT_DIR/${PACKAGE_NAME}_all.deb"

echo
echo "Elkészült:"
echo "$OUTPUT_DIR/${PACKAGE_NAME}_${VERSION}_all.deb"
