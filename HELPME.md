# Introduction

I've been trying to package GOWIN EDA (https://www.gowinsemi.com/en/support/home) for NixOS but haven't had much success... I've pushed my current attempt to a repository (https://github.com/scottwillmoore/nix-gowin-eda), but there have been many more attempts that were not tracked in the repository.

GOWIN EDA is a pre-compiled, closed-source suite of applications therefore cannot be rebuilt from source and must be patched to run on NixOS. The executables are dynamically linked, whereby most dependencies are bundled, but some are expected to be provided by the system.

GOWIN EDA depends on Qt 5. To my knowledge, Qt 5 has core libraries, but also "plugins". These plugins provide the platform integration and other functionality and are not dynamically linked, but instead dynamically loaded. Both the core libraries and plugins are bundled.

# Attempts

I've tried a few of the suggested strategies for packing binaries:

## `buildFHSEnv`

This should be the easiest. Just ensure the libraries required are provided.

I've managed to configure the dynamically linked dependencies required by `gw_ide`, but then the bundled Qt 5 plugins fail to load due to missing dependencies:

```
$ QT_DEBUG_PLUGINS=1 /bin/gw_ide
...
Cannot load library /nix/store/vprxiv05ylsccgjw2dil25i4bki1jkd6-gowin-eda-education-unwrapped-1.9.11.01/plugins/qt/platforms/libqxcb.so: (libxcb-shm.so.0: cannot open shared object file: No such file or directory)
...
```

I tried to add `libsForQt5.qtbase` and `libsForQt5.full` into my environment to address these issues but it still failed with:

```
$ QT_DEBUG_PLUGINS=1 /bin/gw_ide
...
Cannot load library /nix/store/vprxiv05ylsccgjw2dil25i4bki1jkd6-gowin-eda-education-unwrapped-1.9.11.01/plugins/qt/platforms/libqxcb.so: (libxcb-shm.so.0: cannot open shared object file: No such file or directory)
...
```

I then added `xorg.libxcb` and `xorg.xcb*` which resolved the problem, but then failed with:

```
$ QT_DEBUG_PLUGINS=1 /bin/gw_ide
...
loaded library "/nix/store/vprxiv05ylsccgjw2dil25i4bki1jkd6-gowin-eda-education-unwrapped-1.9.11.01/plugins/qt/xcbglintegrations/libqxcb-glx-integration.so"
qt.glx: qglx_findConfig: Failed to finding matching FBConfig for QSurfaceFormat(version 2.0, options QFlags<QSurfaceFormat::FormatOption>(), depthBufferSize -1, redBufferSize 1, greenBufferSize 1, blueBufferSize 1, alphaBufferSize -1, stencilBufferSize -1, samples -1, swapBehavior QSurfaceFormat::SingleBuffer, swapInterval 1, colorSpace QSurfaceFormat::DefaultColorSpace, profile  QSurfaceFormat::NoProfile)
qt.glx: qglx_findConfig: Failed to finding matching FBConfig for QSurfaceFormat(version 2.0, options QFlags<QSurfaceFormat::FormatOption>(), depthBufferSize -1, redBufferSize 1, greenBufferSize 1, blueBufferSize 1, alphaBufferSize -1, stencilBufferSize -1, samples -1, swapBehavior QSurfaceFormat::SingleBuffer, swapInterval 1, colorSpace QSurfaceFormat::DefaultColorSpace, profile  QSurfaceFormat::NoProfile)
Could not initialize GLX
...
```

## `wrapQtAppsHook`

I decide that instead of trying to use the bundled Qt plugins, I should instead replace them with the Qt plugins provided by NixOS. I use `wrapQtAppsHook` with `dontWrapQtApps` and then manually invoke `wrapQtApp` on `gw_ide`.

```
$ QT_DEBUG_PLUGINS=1 /bin/gw_ide
...
Cannot load library /nix/store/h77jn6fm5nll7yk3qk5m2k4qqnpf66a2-qtbase-5.15.16-bin/lib/qt-5.15.16/plugins/platforms/libqxcb.so: (/nix/store/d1i60xvrnfbnd1yrazjixf3ina4bwm1j-gowin-eda-education-unwrapped-1.9.11.01/bin/../lib/libstdc++.so.6: version `GLIBCXX_3.4.29' not found (required by /nix/store/h77jn6fm5nll7yk3qk5m2k4qqnpf66a2-qtbase-5.15.16-bin/lib/qt-5.15.16/plugins/platforms/../../../../../0dpiiqjmhq07s4n6b4zlmk9ny3g5y9vf-qtbase-5.15.16/lib/libQt5XcbQpa.so.5))
...
```

I attempted to delete `libstdc++.so.6` in an attempt to use the NixOS version, but this just created an even scarier error where I decided to give up:

```
...
Cannot load library /nix/store/h77jn6fm5nll7yk3qk5m2k4qqnpf66a2-qtbase-5.15.16-bin/lib/qt-5.15.16/plugins/platforms/libqxcb.so: (/nix/store/h77jn6fm5nll7yk3qk5m2k4qqnpf66a2-qtbase-5.15.16-bin/lib/qt-5.15.16/plugins/platforms/../../../../../0dpiiqjmhq07s4n6b4zlmk9ny3g5y9vf-qtbase-5.15.16/lib/libQt5XcbQpa.so.5: undefined symbol: _ZTI27QPlatformServiceColorPicker, version Qt_5_PRIVATE_API)
...
```

## `autoPatchelfHook`

I had initially tried `autoPatchelfHook` but eventually decided it would probably be easier to start with `buildFHSEnv` to just get it to run. I found `autoPatchelfHook` to be fairly slow to which made it hard to quickly iterate on any problems I encountered.

I alo found `autoPatchelfHook` to be fairly heavy handled and attempted to patch binaries to (quite outdated) libraries found in `./bin/serdes_toml_to_csr.dist/`, etc instead of `./lib` and `/nix`. This was without much configuration, so it might be possible to restrict the search path to get it to work.

# Conclusion

I'm not sure where to go from here...

I remember at some point I was able to package an older version with Flatpak, so I could give that a shot again. From memory Flatpak wasn't a great platform for development utilities when you want to use the utilities from your shell.

It might be important to note that there appears to be some major changes between `Gowin_V1.9.11.01` and `Gowin_V1.9.11`. The `gowin-eda` packages on the AUR has this comment:

> Gowin EDA V1.9.11.01 doesn't work properly(Qt library version incompatibility). We will stick to V1.9.11 until this issue is resolved.
>
> \- https://aur.archlinux.org/packages/gowin-eda-ide#comment-1015480

<details>
<summary>Libraries:</summary>

```diff
$ git diff <(ls Gowin_V1.9.11_linux/IDE/lib/) <(ls Gowin_V1.9.11.01_linux/IDE/lib/)
diff --git a/dev/fd/63 b/dev/fd/62
--- a/dev/fd/63
+++ b/dev/fd/62
@@ -6,66 +6,66 @@ libcrypto.so.10
 libDevice.so
 libEditor.so
 libExtSys.so
-libfreetype.so.6
 libGaoUtils.so
-libgcc_s.so.1
+libGLdispatch.so.0
+libGLX.so.0
 libGowinProxy.so
 libgowin.so
 libGowinSynProxy.so
-libgstapp-0.10.so.0
-libgstbase-0.10.so.0
-libgstinterfaces-0.10.so.0
-libgstpbutils-0.10.so.0
-libgstreamer-0.10.so.0
-libgstvideo-0.10.so.0
 libGvioUtils.so
 libgwsyn.so
 libGWTE.so
-libGWTE.so_old
 libhdlresolve.so
-libICE.so.6
+libicudata.so.56
+libicui18n.so.56
+libicuuc.so.56
 libIDE.so
 libJson.so
 libnetcatcher.so
 libNlsData.so
 libNlsUtils.so
-libphonon.so.4
 libPkgView.so
-libQt3Support.so.4
-libQtCLucene.so.4
-libQtCore.so.4
-libQtDBus.so.4
-libQtDeclarative.so.4
-libQtDesignerComponents.so.4
-libQtDesigner.so.4
-libQtGui.so.4
-libQtHelp.so.4
-libQtMultimedia.so.4
...skipping...
+libpthread.so
+libQt5Concurrent.so.5
+libQt5Core.so.5
+libQt5DBus.so.5
+libQt5Gui.so.5
+libQt5Help.so.5
+libQt5Network.so.5
+libQt5Positioning.so.5
+libQt5PrintSupport.so.5
+libQt5QmlModels.so.5
+libQt5Qml.so.5
+libQt5Quick.so.5
+libQt5QuickWidgets.so.5
+libQt5Sql.so.5
+libQt5Test.so.5
+libQt5WebChannel.so.5
+libQt5WebEngineCore.so.5
+libQt5WebEngine.so.5
+libQt5WebEngineWidgets.so.5
+libQt5WebSockets.so.5
+libQt5Widgets.so.5
+libQt5XcbQpa.so.5
+libQt5Xml.so.5
 libQUtility.so
 libQZip.so
 librtlhierarchy.so
 librtlparser.so
 librtlviewer.so
-libSM.so.6
 libstdc++.so.6
 libtcl8.6.so
 libtclstub8.6.a
 libUtils.so
-libX11.so.6
+libX11.so
 libXau.so.6
+libxcb-icccm.so.4
+libxcb-image.so.0
+libxcb-keysyms.so.1
+libxcb-render-util.so.0
 libxcb.so.1
+libxcb-xinerama.so.0
 libXext.so.6
-libxml2.so.2
 libXrender.so.1
 pkgconfig
 sqlite3.11.0
```

</details>

<details>
<summary>QT plugins:</summary>

```diff
$ git diff <(ls Gowin_V1.9.11_linux/IDE/plugins/qt/) <(ls Gowin_V1.9.11.01_linux/IDE/plugins/qt/)
diff --git a/dev/fd/63 b/dev/fd/62
--- a/dev/fd/63
+++ b/dev/fd/62
@@ -1,12 +1,34 @@
-accessible
+assetimporters
+audio
 bearer
-codecs
+canbus
 designer
-graphicssystems
+egldeviceintegrations
+gamepads
+generic
+geometryloaders
+geoservices
 iconengines
 imageformats
-inputmethods
-phonon_backend
+mediaservice
+platforminputcontexts
+platforms
+platformthemes
+playlistformats
+position
+printsupport
 qmltooling
-script
+renderers
+renderplugins
+sceneparsers
+sensorgestures
+sensors
 sqldrivers
+texttospeech
+virtualkeyboard
+wayland-decoration-client
+wayland-graphics-integration-client
+wayland-graphics-integration-server
+wayland-shell-integration
+webview
+xcbglintegrations
```

</details>
