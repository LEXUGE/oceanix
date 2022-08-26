{ lib, pkgs }:
(import ../stdPkger.nix {
  inherit lib pkgs;
  pname = "opencore";
  path = ./.;
})
