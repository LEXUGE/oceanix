# Upstream: https://github.com/acidanthera/WhateverGreen/releases/
{ lib }: rec {
  latest = v1_6_1;

  v1_6_1 = {
    canonicalVersion = "1.6.1";
    debug = lib.fakeSha256;
    release = "sha256-OjE1Ot6f2wlyiUY2Qu+0IU1vRgVveZXil8PBLuz8StA=";
  };
}
