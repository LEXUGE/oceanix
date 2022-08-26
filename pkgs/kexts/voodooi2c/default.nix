{ lib, pkgs }:
import ../../pkger.nix {
  inherit lib pkgs;
  path = ./.;
  fn = ver: {
    "voodooi2c-${ver}" = pkgs.callPackage ./voodooi2c.nix { inherit ver; };
  };
}
