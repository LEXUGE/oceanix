{
  description = "OpenCore bootloader manager with Nix";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils, ... }:
    rec {
      lib = {
        oc = (import ./lib/stdlib-extended.nix nixpkgs.lib).oc;
        OpenCoreConfig = { modules ? [ ], pkgs, lib ? pkgs.lib
          , extraSpecialArgs ? { }, check ? true }@args:
          (import ./modules {
            inherit pkgs lib check extraSpecialArgs;
            configuration = { ... }: { imports = modules; };
          });
      };

      overlays.default = final: prev:
        (import ./pkgs {
          inherit (prev) lib;
          pkgs = prev;
        });

      tests = {
        buildExampleEfi = (lib.OpenCoreConfig {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [ overlays.default ];
          };

          modules = [
            ({ lib, pkgs, ... }: {
              oceanix.opencore = {
                settings = { Kernel.Add."Lilu.kext".Enabled = true; };
                resources = [
                  pkgs.whatevergreen-latest-release
                  pkgs.lilu-latest-release
                  pkgs.voodooi2c-latest
                  pkgs.intel-mausi-latest-release
                ];
              };
            })
          ];
        }).efiPackage;
      };
    } // utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
      in { packages = (import ./pkgs { inherit lib pkgs; }); });
}
