#!/bin/sh

set -eux

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	kdeconnect       \
	libxtst          \
	pipewire-audio   \
	qt6ct
	
echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini
