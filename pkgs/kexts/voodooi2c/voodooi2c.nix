{ lib, stdenv, fetchzip, ver ? "latest" }:
let versionList = (import ./version.nix { inherit lib; });
in stdenv.mkDerivation rec {
  pname = "voodooi2c";
  version = versionList."${ver}".canonicalVersion;

  src = fetchzip {
    url =
      "https://github.com/VoodooI2C/VoodooI2C/releases/download/${version}/VoodooI2C-${version}.zip";
    sha256 = versionList."${ver}".hash;
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/Kexts
    cp -r . $out/Kexts
  '';
}
