#!/bin/sh

set -eux
export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"
URUNTIME=$(wget -q --retry-connrefused --tries=30 \
	https://api.github.com/repos/VHSgunzo/uruntime/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi "https.*appimage.*dwarfs.*$ARCH$" | head -1)

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

./sharun -g # makes sharun generate the lib.path file
VERSION=$(pacman -Q kdeconnect | awk 'FNR==1 {print $2; exit}')
[ -n "$VERSION" ]
echo "$VERSION" > ~/version

# Make AppImage with uruntime
cd ..
wget -q "$URUNTIME" -O ./uruntime
chmod +x ./uruntime

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
printf "$UPINFO" > data.upd_info
llvm-objcopy --update-section=.upd_info=data.upd_info \
	--set-section-flags=.upd_info=noload,readonly ./uruntime
printf 'AI\x02' | dd of=./uruntime bs=1 count=3 seek=8 conv=notrunc

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f \
	--set-owner 0 --set-group 0 \
	--no-history --no-create-timestamp \
	--compression zstd:level=22 -S26 -B32 \
	--header uruntime \
	-i ./AppDir -o kdeconnect-"$VERSION"-anylinux-"$ARCH".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage
echo "All Done!"
