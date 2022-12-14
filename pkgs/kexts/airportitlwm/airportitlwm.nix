{ lib, stdenv, fetchzip, ver ? "latest", osVer }:
let versionList = (import ./version.nix { inherit lib; });
in stdenv.mkDerivation rec {
  pname = "airportitlwm";
  version = versionList."${ver}".canonicalVersion;

  src = fetchzip {
    url = versionList."${ver}".mkUrl osVer;
    sha256 = versionList."${ver}"."${osVer}";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/Kexts
    cd */
    cp -r . $out/Kexts
  '';
}
