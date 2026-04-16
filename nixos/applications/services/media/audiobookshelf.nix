{ config, ... }:
let
  subdomain = "abs";
  port = 9193;
in
{
  nixarr.audiobookshelf = {
    enable = true;
    openFirewall = true;
    port = port;
  };

  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
