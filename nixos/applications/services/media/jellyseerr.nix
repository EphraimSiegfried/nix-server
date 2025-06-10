{ config, ... }:
let
  subdomain = "js";
  port = 9899;
in
{
  services.jellyseerr = {
    enable = false;
    openFirewall = true;
    port = port;
  };

  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
    };
  };
}
