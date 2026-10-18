{
  lib,
  stdenv,
  fetchurl,

  version ? "1.9.11.03",
  hash ? "sha256-b9OS90c7JNhHtvjr3HoYXFkYJro12NDlF5YQMNRG+fc=",
}:
stdenv.mkDerivation {
  pname = "gowin-eda-education-unwrapped";
  inherit version;

  src = fetchurl {
    url = "https://eda.gowinsemi.cn/Gowin_V${version}_Education_Linux.tar.gz";
    inherit hash;

    # The download is rejected without a browser user agent.
    curlOptsList = [
      "-A"
      "Mozilla/5.0"
    ];
  };

  sourceRoot = "./";

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir --parents --verbose $out/
    cp --preserve=mode --recursive --verbose ./IDE/* $out/

    # These bundled libraries are incompatible with the versions provided by
    # NixOS and must be removed and replaced by the wrapped environment.
    rm --force --verbose \
      $out/lib/libfreetype.so.6 \
      $out/lib/libstdc++.so.6 \
      $out/lib/libGLX.so.0 \
      $out/lib/libGLdispatch.so.0

    chmod --verbose +x $out/bin/gw_ide

    runHook postInstall
  '';

  dontStrip = true;
  dontPatchELF = true;
  dontPatchShebangs = true;

  meta = {
    description = "An EDA suite for designing and developing Gowin FPGAs";
    homepage = "https://www.gowinsemi.com/en/support/home/";
    downloadPage = "https://www.gowinsemi.com/en/support/download_eda/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
