#!/bin/sh

set -eux

ARCH="$(uname -m)"
URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"
VERSION="$(cat ~/version)"

export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export OUTNAME=kdeconnect-"$VERSION"-anylinux-"$ARCH".AppImage
export DESKTOP=/usr/share/applications/org.kde.kdeconnect.app.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/kdeconnect.svg
export DEPLOY_OPENGL=1

# ADD LIBRARIES
wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun \
	/usr/bin/kdeconnect*                  \
	/usr/bin/sshfs                        \
	/usr/bin/sftp                         \
	/usr/lib/libssl.so*                   \
	/usr/lib/libKF6Svg.so*                \
	/usr/lib/libKirigami*                 \
	/usr/lib/libKF6People*                \
	/usr/lib/libKF6Contacts.so*           \
	/usr/lib/libKF6ItemModels.so*         \
	/usr/lib/libQt6Labs*                  \
	/usr/lib/libKF6StatusNotifierItem.so* \
	/usr/lib/libkquickcontrolsprivate.so* \
	/usr/lib/libQt6QuickControls2*        \
	/usr/lib/qt6/plugins/plasma/kcms/*/*  \
	/usr/lib/qt6/plugins/kdeconnect/*     \
	/usr/lib/qt6/plugins/kdeconnect/*/*   \
	/usr/lib/qt6/plugins/kpeople/*/*

# kdeconnect needs this as well
for lib in $(find ./AppDir/lib/qt6/qml -type f -name '*.so*'); do
	ldd "$lib" | awk -F"[> ]" '{print $4}' | xargs -I {} cp -vn {} ./AppDir/lib || :
done

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage

mkdir -p ./dist
mv -v ./*.AppImage* ./dist
mv -v ~/version     ./dist
