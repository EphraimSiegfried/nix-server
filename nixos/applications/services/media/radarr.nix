{ config, ... }:
let
  subdomain = "radarr";
  port = 7878;
in
{
  nixarr.radarr = {
    enable = true;
    openFirewall = true;
  };

  systemd.services.radarr.serviceConfig.UMask = "0002";
  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
    };
  };
}
