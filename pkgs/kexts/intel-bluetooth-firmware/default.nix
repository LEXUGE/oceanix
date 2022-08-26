{ lib, pkgs }:
import ../../pkger.nix {
  inherit lib pkgs;
  path = ./.;
  fn = ver: {
    "intel-bluetooth-firmware-${ver}" =
      pkgs.callPackage ./intel-bluetooth-firmware.nix { inherit ver; };
  };
}
