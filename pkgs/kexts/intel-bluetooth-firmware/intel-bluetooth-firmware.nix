{ lib, stdenv, fetchzip, ver ? "latest" }:
let versionList = (import ./version.nix { inherit lib; });
in stdenv.mkDerivation rec {
  pname = "intel-bluetooth-firmware";
  version = versionList."${ver}".canonicalVersion;

  src = fetchzip {
    url =
      "https://github.com/OpenIntelWireless/IntelBluetoothFirmware/releases/download/${version}/IntelBluetooth-${version}.zip";
    sha256 = versionList."${ver}".hash;
    stripRoot = false;
  };

  installPhase = ''
    mkdir -p $out/Kexts
    cp -r . $out/Kexts
  '';
}
