{ config, ... }:
{
  services.jellyseerr = {
    enable = false;
    openFirewall = true;
    port = 5555;
  };

  services.nginx.virtualHosts."js.${config.domain}" = {
    # enableACME = true;
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.jellyseerr.port}";
      recommendedProxySettings = true;
    };
  };
}
