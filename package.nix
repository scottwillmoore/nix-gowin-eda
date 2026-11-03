{
  lib,
  stdenv,

  gowin-eda-education-unwrapped,

  makeBinaryWrapper,

  copyDesktopItems,
  makeDesktopItem,

  alsa-lib,
  dbus,
  expat,
  fontconfig,
  freetype,
  glib,
  krb5,
  libGL,
  libx11,
  libxcb,
  libxcb-image,
  libxcb-keysyms,
  libxcb-render-util,
  libxcb-wm,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxcursor,
  libxtst,
  nspr,
  nss,
  udev,
  zlib,
}:

let
  inherit (lib) makeLibraryPath;

  pname = "gowin-eda-education";
  version = gowin-eda-education-unwrapped.version;

  runtimeLibraries = [
    # Link-time libraries
    alsa-lib
    dbus
    expat
    fontconfig
    freetype
    glib
    krb5
    libGL
    libx11
    libxcb
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    libxrender
    libxtst
    nspr
    nss
    zlib
    stdenv.cc.cc.lib

    # On-demand libraries
    libxcursor
    udev
  ];

  executables = [
    "gw_ide"
    "gw_sh"
    "gao_sh"
    "gvio_sh"
    "floorplanner"
    "assistant"
    "gao_analyzer"
    "gvio_analyzer"
    "GowinModGen"
    "GowinSynthesis"
    "gw_pkgviewer"
    "gw_sdceditor"
    "gw_goeye"
  ];

in
stdenv.mkDerivation {
  inherit pname version;

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir --parents --verbose $out/bin/

    for executable in ${lib.escapeShellArgs executables}; do
      if [ -e "${gowin-eda-education-unwrapped}/bin/$executable" ]; then
        makeBinaryWrapper "${gowin-eda-education-unwrapped}/bin/$executable" "$out/bin/$executable" \
          --prefix LD_LIBRARY_PATH : "${gowin-eda-education-unwrapped}/lib:${makeLibraryPath runtimeLibraries}" \
          --set-default QT_QPA_PLATFORM xcb
      fi
    done

    # Icons
    install --directory $out/share/icons/hicolor/{scalable,512x512}/apps/
    install --mode 644 ${./gowin-eda.svg} $out/share/icons/hicolor/scalable/apps/gowin-eda.svg
    install --mode 644 ${./gowin-eda.png} $out/share/icons/hicolor/512x512/apps/gowin-eda.png

    # MIME types
    install --directory $out/share/mime/packages/
    install --mode 644 ${./gowin-eda-ide-project.xml} $out/share/mime/packages/gowin-eda-ide-project.xml

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "Gowin EDA IDE Education";
      comment = gowin-eda-education-unwrapped.meta.description;
      exec = "gw_ide -prj %f";
      icon = "gowin-eda";
      categories = [
        "Development"
        "Electronics"
        "IDE"
      ];
      mimeTypes = [
        "application/x-gowin-eda-ide-project"
      ];
      keywords = [
        "gw"
      ];
      startupWMClass = "gw_ide";
    })
  ];

  passthru = {
    unwrapped = gowin-eda-education-unwrapped;
  };

  meta = gowin-eda-education-unwrapped.meta // {
    mainProgram = "gw_ide";
  };
}
