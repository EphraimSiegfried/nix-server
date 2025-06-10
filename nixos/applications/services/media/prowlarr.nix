{ config, ... }:
let
  subdomain = "prowlarr";
  port = 9696;
in
{
  nixarr.prowlarr = {
    enable = true;
    openFirewall = true;
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
