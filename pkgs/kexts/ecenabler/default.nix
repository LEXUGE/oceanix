{ lib, pkgs }:
(import ../../stdPkger.nix {
  inherit lib pkgs;
  pname = "ecenabler";
  path = ./.;
})
