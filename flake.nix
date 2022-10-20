{
  description = "NixOS Benchmarks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages."${system}";
      buildKernel = pkgs.callPackage ./build-kernel.nix {};
    in {
      packages."${system}" = {
        inherit buildKernel;

        default = buildKernel;
      };

      nixosConfigurations.perf-test-01 = nixpkgs.lib.nixosSystem {
        inherit system;

        modules = [
          ({ config, ... }: {
            environment.systemPackages = [
              buildKernel
            ];
          })

          ./modules/perf-test-01.nix
        ];
      };
    };
}
