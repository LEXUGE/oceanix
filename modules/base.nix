{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.oceanix;
  plistFile = oc.plist.toPlist { } cfg.opencore.transposedSettings;
  resources = cfg.opencore.resources;
in
{
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

      autoEnablePlugins = mkOption {
        type = types.bool;
        default = true;
        description =
          "Whether to automatically enable plugins of one kexts if which gets enabled";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.opencore-latest-release;
        description = "The OpenCore package to use";
      };

      transposedSettings = mkOption {
        internal = true;
        type = types.attrsOf types.anything;
        description = "Transposed final OpenCore config";
      };

      settings = mkOption {
        type = types.attrsOf types.anything;
        description = "The OpenCore config written in Nix";
      };

      resources = {
        packages = mkOption {
          type = with types; listOf package;
          default = [ ];
          description =
            "External resources like Kext, Drivers, ACPI files to copy into the final package.";
        };

        ACPIFolders = mkOption {
          type = with types; listOf path;
          default = [ ];
          description =
            "ACPI folders to be copied into the final package, used along with resources.packages";
        };

        KextsFolders = mkOption {
          type = with types; listOf path;
          default = [ ];
          description =
            "Kext folders to be copied into the final package, used along with resources.packages";
        };

        DriversFolders = mkOption {
          type = with types; listOf path;
          default = [ ];
          description =
            "Drivers folders to be copied into the final package, used along with resources.packages";
        };

        ToolsFolders = mkOption {
          type = with types; listOf path;
          default = [ ];
          description =
            "Tools folders to be copied into the final package, used along with resources.packages";
        };
      };
    };
  };

  config = {
    oceanix.opencore.settings = with oc.resolver; {
      ACPI.Add = mkDefaultRecursive (mkACPI cfg.efiIntermediatePackage);
      UEFI.Drivers = mkDefaultRecursive (mkDrivers cfg.efiIntermediatePackage);
      Misc.Tools = mkDefaultRecursive (mkTools cfg.efiIntermediatePackage);
      Kernel.Add = mkDefaultRecursive (mkKexts pkgs cfg.efiIntermediatePackage);
    };

    # BUG: this should inherit settings
    oceanix.opencore.transposedSettings = with oc.resolver; updateManyAttrsByPath
      [
        {
          path = [ "Kernel" "Add" ];
          update = old: finalizeKexts cfg.opencore.autoEnablePlugins old;
        }
        { path = [ "Misc" "Tools" ]; update = old: transpose old; }
        { path = [ "UEFI" "Drivers" ]; update = old: transpose old; }
        {
          path = [ "ACPI" "Add" ];
          update = old: transpose old;
        }
      ]
      cfg.opencore.settings;

    oceanix.efiIntermediatePackage =
      pkgs.runCommand "buildEfiIntermediate" { allowSubstitutes = false; } ''
        mkdir -p $out/

        cp -r --no-preserve=ownership,mode ${cfg.opencore.package}/${cfg.opencore.arch}/EFI $out

        ${concatStringsSep "\n" (lib.lists.map (pkg:
          if (builtins.pathExists "${pkg}/Kexts") && (builtins.readDir "${pkg}/Kexts" != {}) then
            "cp -r --no-preserve=ownership,mode ${pkg}/Kexts/* $out/EFI/OC/Kexts/"
          else
            "") resources.packages)}
        ${concatStringsSep "\n" (lib.lists.map (pkg:
          if (builtins.pathExists "${pkg}/ACPI") && (builtins.readDir "${pkg}/ACPI" != {}) then
            "cp -r --no-preserve=ownership,mode ${pkg}/ACPI/* $out/EFI/OC/ACPI/"
          else
            "") resources.packages)}
        ${concatStringsSep "\n" (lib.lists.map (pkg:
          if (builtins.pathExists "${pkg}/Drivers") && (builtins.readDir "${pkg}/Drivers" != {}) then
            "cp -r --no-preserve=ownership,mode ${pkg}/Drivers/* $out/EFI/OC/Drivers/"
          else
            "") resources.packages)}
        ${concatStringsSep "\n" (lib.lists.map (pkg:
          if (builtins.pathExists "${pkg}/Tools") && (builtins.readDir "${pkg}/Tools" != {}) then
            "cp -r --no-preserve=ownership,mode ${pkg}/Tools/* $out/EFI/OC/Tools/"
          else
            "") resources.packages)}


        ${concatStringsSep "\n" (lib.lists.map (dir:
          if (builtins.readDir dir) != {} then
            "cp -r --no-preserve=ownership,mode ${dir}/* $out/EFI/OC/ACPI/"
          else
            "") resources.ACPIFolders)}

        ${concatStringsSep "\n" (lib.lists.map (dir:
          if (builtins.readDir dir) != {} then
            "cp -r --no-preserve=ownership,mode ${dir}/* $out/EFI/OC/Tools/"
          else
            "") resources.ToolsFolders)}

        ${concatStringsSep "\n" (lib.lists.map (dir:
          if (builtins.readDir dir) != {} then
            "cp -r --no-preserve=ownership,mode ${dir}/* $out/EFI/OC/Drivers/"
          else
            "") resources.DriversFolders)}

        ${concatStringsSep "\n" (lib.lists.map (dir:
          if (builtins.readDir dir) != {} then
            "cp -r --no-preserve=ownership,mode ${dir}/* $out/EFI/OC/Kexts/"
          else
            "") resources.KextsFolders)}
      '';

    oceanix.efiPackage = pkgs.runCommand "buildEfi" { allowSubstitutes = false; } ''
      mkdir -p $out/

      cp -r --no-preserve=ownership,mode ${cfg.efiIntermediatePackage}/EFI $out

      echo "${plistFile}" > $out/EFI/OC/config.plist
    '';
  };
}
