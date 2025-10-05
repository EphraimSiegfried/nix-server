{ config, ... }:
let
  subdomain = "zmittag";
  port = 3991;
in
{
  services.lunch-basel = {
    enable = true;
    lunchfPort = port;
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
