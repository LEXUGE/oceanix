# Upstream: https://github.com/acidanthera/AppleALC/releases/
{ lib }: rec {
  latest = v1_7_5;

  v1_7_5 = {
    canonicalVersion = "1.7.5";
    debug = "sha256-FFVofraDrstRfqpva5XoB9TRxuI+4HXsI7yNgBSo1l8=";
    release = "sha256-3I7mD2VE6aP7POFMVljz4aFN3rfSb0Tbc3yjrepIlG0=";
  };

  v1_7_4 = {
    canonicalVersion = "1.7.4";
    debug = "sha256-UOcgQyC8fgTgvWk3Tw5NMnvy7v9CLma84c+EyOhOb9k=";
    release = "sha256-+/VXE9tRXNSHduQrxJ1TjuNCJ3kBaBqg4vNzxhylmLE=";
  };
}
