{
  stdenv,

  fetchurl,

  wrapQtAppsHook,
}:
let
  inherit (stdenv) mkDerivation;

  hash = "sha256-I26TSznMquS74NZzgJtRDMQ4V9hg7z4WCSJ0ybkvrQ4=";
  version = "1.9.11.01";
in
mkDerivation {
  inherit version;
  pname = "gowin-eda-education-unwrapped";

  src = fetchurl {
    inherit hash;
    url = "https://cdn.gowinsemi.com.cn/Gowin_V${version}_Education_Linux.tar.gz";
  };

  nativeBuildInputs = [
    wrapQtAppsHook
  ];

  sourceRoot = "./";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir --parents --verbose $out/
    cp --no-preserve=mode --recursive --verbose ./IDE/* $out/
    rm --recursive --verbose $out/plugins/qt/
    rm --verbose $out/lib/libstdc++.so.6

    chmod --verbose +x $out/bin/gw_ide
    wrapQtApp $out/bin/gw_ide

    runHook postInstall
  '';

  dontStrip = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  dontWrapQtApps = true;
}
