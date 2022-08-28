# oceanix
OpenCore bootloader manager with Nix

# Features
## Automatic Configuration Defaults
*New OpenCore version is out with tons of new options and quirks, but how should I update my existing config?* Oceanix will automatically read the `Sample.plist` in your chosen OpenCore package and set default values accordingly. This means you only need to write changes on top of it, which makes you config a lot more readable and manageable.  

Moreover, when next time new options are introduced, the defaults will automatically upgrade as the OpenCore package does, and you will only need to resolve removed options. That's a big deal.

## Programmable OpenCore Configuration
*Feel like your configuration is too long to grasp? Why not structure it into separate sections?* With oceanix, you can write your OpenCore config *entirely* in Nix Language which allows you to easily comment, structure, and even program your config however you like.

## Flexible Package Management
*Your favorite kexts packaged!* Popular (or even essential) kernel extensions like `WhateverGreen`, `Lilu`, and `AirportItlwm` are all packaged across different versions as well as variants (`DEBUG`, `RELEASE`, etc). If you need other kexts or drivers, you could easily package them yourself or use options like `kextsFolders` to plug your kexts collection on fly.

## Easy Dependency Upgrade / Downgrade
*No need to visit release page, download, unzip, and copy anymore!* Thanks to package management, you could update your kexts or any other resources without touching your config. Simply use `whatevergreen-latest-release` and rebuild your config.  

If you would like to downgrade your kexts to debug, just go `whatevergreen-v1_6_1-debug`.

## Proper Dependency Resolution
Oceanix comes with kexts dependency resolution which resolves dependency of your kexts and order them according to OpenCore specification, just like what ProperTree will do for you.  

What's different is oceanix allows you to finely toggle your kexts. You can recursively disable a kexts and its plugins with a single flip as oceanix understands the dependency graph.

## Reproducible EFI
Secured by Nix, Your EFI is guaranteed bit-by-bit same given the same configuration. No more configuration drifts.

# Usage
This section is under heavy development.  

## Steps
1. Install [nix](https://nixos.org) and [enable flake support](https://nixos.wiki/wiki/Flakes).
2. Create a new flake with `flake.nix` like
```nix
{
  description = "My OpenCore config managed by oceanix";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.utils.url = "github:numtide/flake-utils";
  inputs.oceanix.url = "github:LEXUGE/oceanix";

  outputs = { self, nixpkgs, utils, oceanix, ... }:
    utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      {
        packages = rec {
          x1c7 = (oceanix.lib.OpenCoreConfig {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ oceanix.overlays.default ];
            };

            modules = [
              ./modules/x1c7
            ];
          }).efiPackage;
          default = x1c7;
        };
      });
}
```
3. Write your configuration
3. Run `nix build`

# Configuration
See [my personal config](https://github.com/LEXUGE/opencore-cfg) as an example.
