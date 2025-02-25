# kdeconnect-AppImage

By default running the AppImage will launch `kdeconnect-app`.

In order to launch `kdeconnect-cli`, `kdeconnect-indicator`, `kdeconnectd`. you can symlink the AppImage to those names, and by launching the symlinks the AppImage will know that you want to run that binary instead. You can also pass the binaries as the first argument to the AppImage as well. 

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks. 

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

**It also uses the [uruntime](https://github.com/VHSgunzo/uruntime) which makes use of dwarfs, resulting in a smaller and faster AppImage.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend this alternative instead: https://github.com/ivan-hc/AM

This AppImage works without fuse2 as it can use fuse3 instead.
