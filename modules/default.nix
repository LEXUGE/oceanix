{ configuration
, pkgs
, lib ? pkgs.lib

  # Whether to check that each option has a matching declaration.
, check ? true
  # Extra arguments passed to specialArgs.
, extraSpecialArgs ? { }
}:

with lib;

let

  collectFailed = cfg:
    map (x: x.message) (filter (x: !x.assertion) cfg.assertions);

  extendedLib = import ../lib/stdlib-extended.nix lib;

  ocModules = import ./modules.nix {
    inherit check pkgs;
    lib = extendedLib;
  };

  rawModule = extendedLib.evalModules {
    modules = [ configuration ] ++ ocModules;
    specialArgs = { modulesPath = builtins.toString ./.; } // extraSpecialArgs;
  };

  module =
    let
      failed = collectFailed rawModule.config;
      failedStr = concatStringsSep "\n" (map (x: "- ${x}") failed);
    in
    if failed == [ ] then
      rawModule
    else
      throw ''

      Failed assertions:
      ${failedStr}'';

in
{
  inherit (module) options config;

  efiPackage = module.config.oceanix.efiPackage;

  # inherit (module._module.args) pkgs;
}
