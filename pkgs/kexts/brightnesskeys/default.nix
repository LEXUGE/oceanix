{ lib, pkgs }:
(import ../../stdPkger.nix {
  inherit lib pkgs;
  pname = "brightnesskeys";
  path = ./.;
})
