{
  description = "NixOS Benchmarks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, deploy-rs }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages."${system}";
      lib = nixpkgs.lib;

      buildKernel = pkgs.callPackage ./build-kernel.nix {};
    in {
      packages."${system}" = {
        inherit buildKernel;

        default = buildKernel;
      };

      devShells."${system}".default = pkgs.mkShell {
        packages = [
          deploy-rs.packages."${system}".default
        ];
      };

      nixosConfigurations.perf-test-01 = lib.nixosSystem {
        inherit system;

        modules = [
          ({ config, ... }: {
            environment.systemPackages = [
              buildKernel
            ];
          })

          ./modules/perf-test-01.nix
          ./modules/common.nix
        ];
      };

      deploy.nodes.perf-test-01 = {
        hostname = "116.202.108.9";

        profiles.system = {
          sshUser = "root";
          user = "root";

          path = deploy-rs.lib."${system}".activate.nixos self.nixosConfigurations.perf-test-01;
        };
      };
    };
}
