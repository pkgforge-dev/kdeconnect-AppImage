#!/bin/sh

set -eux

ARCH="$(uname -m)"
VERSION="$(cat ~/version)"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=kdeconnect-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/org.kde.kdeconnect.app.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/kdeconnect.svg

# Prepare AppDir
mkdir -p ./AppDir/share/applications
cd ./AppDir

cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(cd "${0%/*}" && echo "$PWD")"
APPIMAGE="${APPIMAGE:-$0}"
DATADIR="${XDG_DATA_HOME:-$HOME/.local/share}"
KDE_DBUS="$DATADIR"/dbus-1/services/org.kde.kdeconnect.service
BIN="${ARGV0#./}"
unset ARGV0

if ! grep -q "\"$APPIMAGE\" kdeconnectd" "$KDE_DBUS"; then
	>&2 echo "Adding kdeconnect dbus service to $DATADIR/dbus-1/services"
	mkdir -p "$DATADIR"/dbus-1/services
	printf '%s\n%s\n%s\n' \
		'[D-BUS Service]' \
		'Name=org.kde.kdeconnect' \
		"Exec=\"$APPIMAGE\" kdeconnectd" > "$KDE_DBUS"
fi

if [ -f "$CURRENTDIR/bin/$BIN" ]; then
	exec "$CURRENTDIR/bin/$BIN" "$@"
elif [ -f "$CURRENTDIR/bin/$1" ]; then
	BIN="$1"
	shift
	exec "$CURRENTDIR/bin/$BIN" "$@"
else
	exec "$CURRENTDIR/bin/kdeconnect-app" "$@"
fi
EOF
chmod +x ./AppRun

# ADD LIBRARIES
wget "$LIB4BN" -O ./lib4bin
chmod +x ./lib4bin
xvfb-run -a -- ./lib4bin -p -v -e -s -k \
	/usr/bin/kdeconnect* \
	/usr/bin/sshfs \
	/usr/bin/sftp \
	/usr/lib/libssl.so* \
	/usr/lib/libKF6Svg.so* \
	/usr/lib/libKirigami* \
	/usr/lib/libKF6People* \
	/usr/lib/libKF6Contacts.so* \
	/usr/lib/libKF6ItemModels.so* \
	/usr/lib/libQt6Labs* \
	/usr/lib/libKF6StatusNotifierItem.so* \
	/usr/lib/libkquickcontrolsprivate.so* \
	/usr/lib/libQt6QuickControls2* \
	/usr/lib/qt6/plugins/plasma/kcms/*/* \
	/usr/lib/qt6/plugins/kdeconnect/* \
	/usr/lib/qt6/plugins/kdeconnect/*/* \
	/usr/lib/qt6/plugins/kpeople/*/* \
	/usr/lib/qt6/plugins/multimedia/* \
	/usr/lib/qt6/plugins/iconengines/* \
	/usr/lib/qt6/plugins/imageformats/* \
	/usr/lib/qt6/plugins/platforms/* \
	/usr/lib/qt6/plugins/platformthemes/* \
	/usr/lib/qt6/plugins/styles/* \
	/usr/lib/qt6/plugins/tls/* \
	/usr/lib/qt6/plugins/xcbglintegrations/* \
	/usr/lib/qt6/plugins/wayland-*/*

# kdeconnect needs this as well
cp -rv /usr/lib/qt6/qml ./shared/lib/qt6
./sharun -g

# make appimage with uruntime
cd ..
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage
