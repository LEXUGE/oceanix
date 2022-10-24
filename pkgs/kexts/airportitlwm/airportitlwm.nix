{ lib, stdenv, fetchzip, ver ? "latest", osVer }:
let versionList = (import ./version.nix { inherit lib; });
in stdenv.mkDerivation rec {
  pname = "airportitlwm";
  version = versionList."${ver}".canonicalVersion;

  src = fetchzip {
    url =
      # Hacky work around
      if (builtins.compareVersions version "v2.1.0") != 1 then "https://github.com/OpenIntelWireless/itlwm/releases/download/${version}/AirportItlwm_${version}_stable_${osVer}.kext.zip" else "https://github.com/OpenIntelWireless/itlwm/releases/download/${version}-alpha/AirportItlwm-${osVer}-${version}-DEBUG-alpha-ee56708.zip";
    sha256 = versionList."${ver}"."${osVer}";
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/Kexts
    cd */
    cp -r . $out/Kexts
  '';
}
