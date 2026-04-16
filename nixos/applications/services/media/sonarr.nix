{ config, ... }:
let
  subdomain = "sonarr";
  port = 8989;
in
{
  nixarr.sonarr = {
    enable = true;
    openFirewall = true;
  };
  systemd.services.sonarr.serviceConfig.UMask = "0002";
  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
    };
  };
}
