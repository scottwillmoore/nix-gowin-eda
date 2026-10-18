{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };

      gowinPackages = import ./default.nix { inherit pkgs; };
    in
    {
      packages.${system} = gowinPackages // {
        default = gowinPackages.gowin-eda-education;
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
