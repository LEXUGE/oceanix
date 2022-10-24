# Upstream: https://github.com/OpenIntelWireless/itlwm/releases

{ lib }: rec {
  latest = v2_2_0;

  v2_2_0 = {
    canonicalVersion = "v2.2.0";
    # Big_Sur = lib.fakeSha256;
    Catalina = "sha256-ffz0g7a5J09Iuxi7vbyGyeuj9Ykx8hSym+w0Xt2e8wo=";
    Monterey = "sha256-xEfMfU3r4RSRikEuq8SjdF4fVbtpNlnbYfvW6OAn0nk=";
    Ventura = "sha256-Dckhcqx/aKc2eVcXV+cQMmrbHkX5S5GlmoQ8y7iGx6M=";
  };

  v2_1_0 = {
    canonicalVersion = "v2.1.0";
    BigSur = "sha256-F6xjLHWF0mAwKpdYbXjM05E8qZoWTmg3U/6NHGnF5i8=";
    Catalina = "sha256-zan+kADmvGgvmlECfTk4Ne/qb263xRtkZYddSAcV84U=";
    Monterey = "sha256-D/xkAKHsuYCLqz43E4OhcsfDbSzK57J/FUcovuPOiHM=";
  };
}
