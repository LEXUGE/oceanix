# Upstream: https://github.com/acidanthera/BrcmPatchRAM/releases/
{ lib }: rec {
  latest = v2_6_4;

  v2_6_4 = {
    canonicalVersion = "2.6.4";
    debug = "sha256-WOL96RB1NLtIfZ9qGEppS/GyP9fCzljYI/Pb2MZuzLM=";
    release = "sha256-WOL96RB1NLtIfZ9qGEppS/GyP9fCzljYI/Pb2MZuzLM=";
  };

  v2_6_3 = {
    canonicalVersion = "2.6.3";
    debug = "sha256-/tdO3dKZf2boJJAZH8Dx5olPdaK0Uvpm5QFd5cAPADk=";
    release = "sha256-ibeU2Wu77zJbs4H3rgGbAceJ/jTv4vTTBKdfmOw2ez4=";
  };
}
