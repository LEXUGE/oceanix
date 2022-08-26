{ lib, pkgs, pname, path }:
import ./pkger.nix {
  inherit lib pkgs path;
  fn = ver: {
    "${pname}-${ver}-debug" = pkgs.callPackage (path + "/${pname}.nix") {
      inherit ver;
      release = false;
    };

    "${pname}-${ver}-release" =
      pkgs.callPackage (path + "/${pname}.nix") { inherit ver; };
  };
}
