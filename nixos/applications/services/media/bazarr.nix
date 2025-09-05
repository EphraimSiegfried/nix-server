{ config, ... }:
let
  subdomain = "bazarr";
  port = 6767;
in
{
  nixarr.bazarr = {
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
