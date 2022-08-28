{
  description = "OpenCore bootloader manager with Nix";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, utils, ... }: with utils.lib;
    rec {
      lib = {
        oc = (import ./lib/stdlib-extended.nix nixpkgs.lib).oc;
        OpenCoreConfig =
          { modules ? [ ]
          , pkgs
          , lib ? pkgs.lib
          , extraSpecialArgs ? { }
          , check ? true
          }@args:
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
            system = system.x86_64-linux;
            overlays = [ overlays.default ];
          };

          modules = [
            ({ lib, pkgs, ... }: {
              oceanix.opencore = {
                resources.packages = [
                  pkgs.airportitlwm-latest-stable-big_sur
                  pkgs.applealc-latest-release
                  pkgs.brightnesskeys-latest-release
                  pkgs.ecenabler-latest-release
                  pkgs.intel-bluetooth-firmware-latest
                  pkgs.nvmefix-latest-release
                  pkgs.virtualsmc-latest-release
                  pkgs.whatevergreen-latest-release
                  pkgs.lilu-latest-release
                  pkgs.voodooi2c-latest
                  pkgs.voodoops2controller-latest-release
                  pkgs.intel-mausi-latest-release
                ];
              };
            })
          ];
        }).efiPackage;
      };
    } // eachSystem [ system.i686-linux system.x86_64-linux system.x86_64-darwin ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;
      in
      {
        packages = (import ./pkgs { inherit lib pkgs; });
        apps = rec {
          fmt = utils.lib.mkApp {
            drv = with import nixpkgs { inherit system; };
              pkgs.writeShellScriptBin "oceanix-fmt" ''
                export PATH=${
                  pkgs.lib.strings.makeBinPath [
                    findutils
                    nixpkgs-fmt
                    shfmt
                    shellcheck
                  ]
                }
                find . -type f -name '*.sh' -exec shellcheck {} +
                find . -type f -name '*.sh' -exec shfmt -w {} +
                find . -type f -name '*.nix' -exec nixpkgs-fmt {} +
              '';
          };
          default = fmt;
        };
      });
}
