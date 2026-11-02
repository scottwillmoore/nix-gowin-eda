{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfreePredicate = pkg: lib.hasPrefix "gowin-eda" (lib.getName pkg);
      };

      gowinPackages = import ./default.nix { inherit pkgs; };
    in
    {
      packages.${system} = gowinPackages // {
        default = gowinPackages.gowin-eda-education;
      };

      overlays.default = final: _: import ./default.nix { pkgs = final; };

      checks.${system} = import ./checks.nix {
        inherit (pkgs) runCommand;
        inherit (gowinPackages) gowin-eda-education;
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
