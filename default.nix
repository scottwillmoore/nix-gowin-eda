{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) callPackage;

  gowin-eda-education-unwrapped = callPackage ./package-unwrapped.nix { };
  gowin-eda-education = callPackage ./package.nix {
    inherit gowin-eda-education-unwrapped;
  };
in
{
  inherit
    gowin-eda-education-unwrapped
    gowin-eda-education
    ;
}
