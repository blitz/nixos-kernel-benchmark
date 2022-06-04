{
  description = "NixOS Benchmarks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = let
          buildKernel = pkgs.callPackage ./build-kernel.nix {};
        in {
          inherit buildKernel;

          default = buildKernel;
        };
      }
    );
}
