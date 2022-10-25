{ lib, stdenv, fetchzip, ver ? "latest" }:
let versionList = (import ./version.nix { inherit lib; });
in stdenv.mkDerivation rec {
  pname = "itlwm";
  version = versionList."${ver}".canonicalVersion;

  src = fetchzip {
    inherit (versionList."${ver}") url sha256;
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/Kexts
    cp -r ./*.kext $out/Kexts
  '';
}
