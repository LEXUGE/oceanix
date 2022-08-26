{ lib, stdenv, fetchzip, rsync, release ? true, ver ? "latest" }:
let versionList = (import ./version.nix { inherit lib; });
in stdenv.mkDerivation rec {
  pname = "opencore-${if release then "release" else "debug"}";
  version = versionList."${ver}".canonicalVersion;

  src = fetchzip {
    url =
      "https://github.com/acidanthera/OpenCorePkg/releases/download/${version}/OpenCore-${version}-${
        if release then "RELEASE" else "DEBUG"
      }.zip";
    sha256 = versionList."${ver}"."${if release then "release" else "debug"}";
    stripRoot = false;
  };

  nativeBuildInputs = [ rsync ];

  installPhase = ''
    mkdir $out
    cp -r . $out
  '';
}
