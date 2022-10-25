# Upstream: https://github.com/OpenIntelWireless/itlwm/releases

{ lib }: rec {
  latest = v2_2_0_alpha;

  v2_2_0_alpha = {
    canonicalVersion = "v2.2.0-alpha";
    url = "https://github.com/OpenIntelWireless/itlwm/releases/download/v2.2.0-alpha/itlwm-v2.2.0-DEBUG-alpha-ee56708.zip";
    sha256 = "sha256-AIKVSJrD2+tW9BboQQ5MdoR+XEVoATZt7Qezlkp0JXs=";
  };

  v2_1_0 = {
    canonicalVersion = "v2.1.0";
    url = "https://github.com/OpenIntelWireless/itlwm/releases/download/v2.1.0/itlwm_v2.1.0_stable.kext.zip";
    sha256 = "sha256-6MzyYWCohJiLNzFYpnCh5GkIQPUh6vw6iSJv/WVnfmE=";
  };
}
