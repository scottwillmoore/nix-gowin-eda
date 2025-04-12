{
  pkgs ? import <nixpkgs> { },
}:
let
  inherit (pkgs) callPackage libsForQt5;
in
rec {
  gowin-eda-education = callPackage ./package.nix { inherit gowin-eda-education-unwrapped; };
  gowin-eda-education-unwrapped = libsForQt5.callPackage ./package-unwrapped.nix { };
}
