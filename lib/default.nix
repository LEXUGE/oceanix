{ lib }:

rec {
  dag = import ./dag.nix { inherit lib; };

  plist = import ./plist.nix { inherit lib; };

  resolver = import ./resolver.nix { inherit lib; };
}
