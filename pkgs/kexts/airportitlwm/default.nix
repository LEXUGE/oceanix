{ lib, pkgs }:
import ../../pkger.nix {
  inherit lib pkgs;
  path = ./.;
  fn = ver: {
    "airportitlwm-${ver}-stable-big_sur" = pkgs.callPackage ./airportitlwm.nix { inherit ver; osVer = "BigSur"; };
    "airportitlwm-${ver}-stable-catalina" = pkgs.callPackage ./airportitlwm.nix { inherit ver; osVer = "Catalina"; };
    "airportitlwm-${ver}-stable-monterey" = pkgs.callPackage ./airportitlwm.nix { inherit ver; osVer = "Monterey"; };
  };
}
