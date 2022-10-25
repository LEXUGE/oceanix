{ lib, pkgs }:
(import ../../pkger.nix rec {
  inherit lib pkgs;
  path = ./.;
  fn = let pname = "itlwm"; in ver: {
    "${pname}-${ver}" = pkgs.callPackage (path + "/${pname}.nix") {
      inherit ver;
    };
  };
})
