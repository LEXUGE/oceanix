{ lib, pkgs, fn, path }:
(lib.attrsets.foldAttrs (n: col: col // n) { }
  (lib.attrsets.mapAttrsToList (ver: x: (fn ver))
    (import (path + "/version.nix") { inherit lib; })))
