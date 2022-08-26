# Just a convenience function that returns the given Nixpkgs standard
# library extended with the oceanix library.

nixpkgsLib:

let mkOcLib = import ./.;
in nixpkgsLib.extend (self: super: { oc = mkOcLib { lib = self; }; })
