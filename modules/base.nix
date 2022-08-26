{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.oceanix;
  plistFile = oc.plist.toPlist { } cfg.opencore.settings;
in {
  options.oceanix = {
    efiPackage = mkOption {
      internal = true;
      type = types.package;
      description = "The package containing the complete EFI folder";
    };

    efiIntermediatePackage = mkOption {
      internal = true;
      type = types.package;
      description = "The package containing everything but the config in EFI";
    };

    opencore = {
      arch = mkOption {
        type = types.enum [ "IA32" "X64" ];
        default = "X64";
        description = "The architecture to install OpenCore with";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.opencore-latest-release;
        description = "The OpenCore package to use";
      };

      settings = mkOption {
        type = types.attrsOf types.anything;
        description = "The OpenCore config written in Nix";
      };

      resources = mkOption {
        type = with types; listOf package;
        default = [ ];
        description =
          "External resources like Kext, Drivers, ACPI files to copy into the final package.";
      };
    };
  };

  config = {
    oceanix.opencore.settings.ACPI.Add =
      lib.mkDefault (lib.oc.resolver.mkACPI cfg.efiIntermediatePackage);
    oceanix.opencore.settings.UEFI.Drivers =
      lib.mkDefault (lib.oc.resolver.mkDrivers cfg.efiIntermediatePackage);
    oceanix.opencore.settings.Kernel.Add =
      lib.mkDefault (lib.oc.resolver.mkKexts cfg.efiIntermediatePackage);

    oceanix.efiIntermediatePackage =
      pkgs.runCommand "buildEfiIntermediate" { } ''
        mkdir -p $out/

        cp -r --no-preserve=ownership,mode ${cfg.opencore.package}/${cfg.opencore.arch}/EFI $out

        ${concatStringsSep "\n" (lib.lists.map (pkg:
          if builtins.pathExists "${pkg}/Kexts" then
            "cp -r --no-preserve=ownership,mode ${pkg}/Kexts/* $out/EFI/OC/Kexts/"
          else
            "") cfg.opencore.resources)}
        ${concatStringsSep "\n" (lib.lists.map (pkg:
          if builtins.pathExists "${pkg}/ACPI" then
            "cp -r --no-preserve=ownership,mode ${pkg}/ACPI/* $out/EFI/OC/ACPI/"
          else
            "") cfg.opencore.resources)}
        ${concatStringsSep "\n" (lib.lists.map (pkg:
          if builtins.pathExists "${pkg}/Drivers" then
            "cp -r --no-preserve=ownership,mode ${pkg}/Drivers/* $out/EFI/OC/Drivers/"
          else
            "") cfg.opencore.resources)}
      '';

    oceanix.efiPackage = pkgs.runCommand "buildEfi" { } ''
      mkdir -p $out/

      cp -r --no-preserve=ownership,mode ${cfg.efiIntermediatePackage}/EFI $out

      echo "${plistFile}" > $out/EFI/OC/config.plist
    '';
  };
}
