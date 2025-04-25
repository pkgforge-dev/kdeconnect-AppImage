#!/bin/sh

set -eux
export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"

# Prepare AppDir
mkdir -p ./AppDir/share/applications
cd ./AppDir

cp -v /usr/share/applications/org.kde.kdeconnect.app.desktop ./
cp -v /usr/share/applications/org.kde.kdeconnect.* ./share/applications
cp -v /usr/share/icons/hicolor/scalable/apps/kdeconnect.svg ./
cp -v /usr/share/icons/hicolor/scalable/apps/kdeconnect.svg ./.DirIcon

cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
APPIMAGE="${APPIMAGE:-$(readlink -f "$0")}"
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
	/usr/lib/libKF6StatusNotifierItem.so* \
	/usr/lib/libkquickcontrolsprivate.so* \
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
VERSION=$(pacman -Q kdeconnect | awk 'FNR==1 {print $2; exit}')
[ -n "$VERSION" ]
echo "$VERSION" > ~/version

# make appimage with uruntime
cd ..
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime
wget --retry-connrefused --tries=30 "$URUNTIME_LITE" -O ./uruntime-lite
chmod +x ./uruntime*

# Keep the mount point (speeds up launch time) 
sed -i 's|URUNTIME_MOUNT=[0-9]|URUNTIME_MOUNT=0|' ./uruntime-lite

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression lzma -S24 -B8 \
	--header uruntime-lite \
	-i ./AppDir -o kdeconnect-"$VERSION"-anylinux-"$ARCH".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage
echo "All Done!"
