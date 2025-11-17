#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q kdeconnect | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=/usr/share/applications/org.kde.kdeconnect.app.desktop
export ICON=/usr/share/icons/hicolor/scalable/apps/kdeconnect.svg
export DEPLOY_OPENGL=1

# ADD LIBRARIES
quick-sharun \
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

# Turn AppDir into AppImage
quick-sharun --make-appimage
