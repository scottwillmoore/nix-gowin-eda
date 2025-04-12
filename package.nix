{
  buildFHSEnv,

  gowin-eda-education-unwrapped,
}:
let
  inherit (gowin-eda-education-unwrapped) version;
in
buildFHSEnv {
  inherit version;
  pname = "gowin-eda-education";

  targetPkgs =
    pkgs:
    [ gowin-eda-education-unwrapped ]
    ++ (with pkgs; [
      alsa-lib
      dbus
      expat
      fontconfig
      freetype
      glib
      krb5
      libGL
      libxkbcommon
      nspr
      nss
      zlib
    ])
    ++ (with pkgs.xorg; [
      libX11
      libXcomposite
      libXdamage
      libXfixes
      libXrandr
      libXtst
    ]);
}
