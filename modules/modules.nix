# All modules that need to be evaluated
{ pkgs

  # Note, this should be "the standard library" + HM extensions.
, lib

  # Whether to enable module type checking.
, check ? true
}:

with lib;

let
  modules = [
    ./base.nix
    (pkgs.path + "/nixos/modules/misc/assertions.nix")
    (pkgs.path + "/nixos/modules/misc/meta.nix")

    {
      _module.args.pkgs = lib.mkDefault pkgs;
      _module.check = check;
    }
  ];

in
modules
