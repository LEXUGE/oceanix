{ lib, pkgs }:
import ../../pkger.nix {
  inherit lib pkgs;
  path = ./.;
  fn = ver: {
    "airportitlwm-${ver}-big_sur" = pkgs.callPackage ./airportitlwm.nix {
      inherit ver;
      osVer = "BigSur";
    };
    "airportitlwm-${ver}-catalina" =
      pkgs.callPackage ./airportitlwm.nix {
        inherit ver;
        osVer = "Catalina";
      };
    "airportitlwm-${ver}-monterey" =
      pkgs.callPackage ./airportitlwm.nix {
        inherit ver;
        osVer = "Monterey";
      };
  } // (if ver != "v2_1_0" then {
    "airportitlwm-${ver}-ventura" = pkgs.callPackage ./airportitlwm.nix
      {
        inherit ver;
        osVer = "Ventura";
      };
  } else { });
}
