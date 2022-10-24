# Upstream: https://github.com/acidanthera/VoodooPS2/releases
{ lib }: rec {
  latest = v2_3_1;

  v2_3_1 = {
    canonicalVersion = "2.3.1";
    debug = "sha256-+MF13/H/wdybu1G9zZlx/Mn8AxfW3e+RC5kN3u6dQS4=";
    release = "sha256-avfzf6fOVc/s7/8t2snoOZ/1DiiO5l3UG1Jd5V/fYkg=";
  };

  v2_3_0 = {
    canonicalVersion = "2.3.0";
    debug = "sha256-FdgKSmgZGJ6HmiFmjjIoJvQjWio2gT6Iwn0VEO/7q9E=";
    release = "sha256-tozaVAGknakb6azYcke9nr39DzX0z7E86HfqNOmi3gA=";
  };

  v2_2_9 = {
    canonicalVersion = "2.2.9";
    debug = "sha256-kdCaNv6xj1Hco0XY8KvT6G5fQR2V/mitQFM+29zLpXw=";
    release = "sha256-hNGMeFFJN5842C4sQsefgAf/0UtmT7AW3OEVeWua4lw=";
  };
}
