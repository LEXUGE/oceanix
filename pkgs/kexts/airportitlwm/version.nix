# Upstream: https://github.com/OpenIntelWireless/itlwm/releases

{ lib }: rec {
  latest = v2_2_0_alpha;

  v2_2_0_alpha = {
    canonicalVersion = "v2.2.0-alpha";
    supportedOS = [ "BigSur" "Catalina" "Monterey" "Ventura" ];
    mkUrl = osVer: "https://github.com/OpenIntelWireless/itlwm/releases/download/v2.2.0-alpha/AirportItlwm-${if osVer == "BigSur" then "Big_Sur" else osVer}-v2.2.0-DEBUG-alpha-ee56708.zip";
    BigSur = "sha256-nPROo6iC0kybGRXdoaoGxzJPLcmxNT40d0qzxSc2ZCg=";
    Catalina = "sha256-ffz0g7a5J09Iuxi7vbyGyeuj9Ykx8hSym+w0Xt2e8wo=";
    Monterey = "sha256-xEfMfU3r4RSRikEuq8SjdF4fVbtpNlnbYfvW6OAn0nk=";
    Ventura = "sha256-Dckhcqx/aKc2eVcXV+cQMmrbHkX5S5GlmoQ8y7iGx6M=";
  };

  v2_1_0 = {
    canonicalVersion = "v2.1.0";
    supportedOS = [ "BigSur" "Catalina" "Monterey" ];
    mkUrl = osVer: "https://github.com/OpenIntelWireless/itlwm/releases/download/v2.1.0/AirportItlwm_v2.1.0_stable_${osVer}.kext.zip";
    BigSur = "sha256-F6xjLHWF0mAwKpdYbXjM05E8qZoWTmg3U/6NHGnF5i8=";
    Catalina = "sha256-zan+kADmvGgvmlECfTk4Ne/qb263xRtkZYddSAcV84U=";
    Monterey = "sha256-D/xkAKHsuYCLqz43E4OhcsfDbSzK57J/FUcovuPOiHM=";
  };
}
