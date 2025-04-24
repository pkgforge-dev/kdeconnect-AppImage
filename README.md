# kdeconnect-AppImage

By default running the AppImage will launch `kdeconnect-app`.

In order to launch `kdeconnect-cli`, `kdeconnect-indicator`, `kdeconnectd`. you can symlink the AppImage to those names, and by launching the symlinks the AppImage will know that you want to run that binary instead. You can also pass the binaries as the first argument to the AppImage as well. 

AppImage made using [sharun](https://github.com/VHSgunzo/sharun), which makes it extremely easy to turn any binary into a portable package without using containers or similar tricks.

**This AppImage bundles everything and should work on any linux distro, even on musl based ones.**

It is possible that this appimage may fail to work with appimagelauncher, I recommend these alternatives instead: 

* [AM](https://github.com/ivan-hc/AM) `am -i kdeconnect` or `appman -i kdeconnect`

* [dbin](https://github.com/xplshn/dbin) `dbin install kdeconnect.appimage`

* [soar](https://github.com/pkgforge/soar) `soar install kdeconnect`

This appimage works without fuse2 as it can use fuse3 instead, it can also work without fuse at all thanks to the [uruntime](https://github.com/VHSgunzo/uruntime)

<details>
  <summary><b><i>raison d'être</i></b></summary>
    <img src="https://github.com/user-attachments/assets/d40067a6-37d2-4784-927c-2c7f7cc6104b" alt="Inspiration Image">
  </a>
</details>

