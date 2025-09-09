{ config, ... }:
let
  name = "mealie";
  port = 9281;
  url = "${name}.${config.domain}";
in
{
  services.mealie = {
    enable = true;
    port = port;
    settings = {
      BASE_URL = url;
    };
  };
  services.nginx.virtualHosts."${url}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
    };
  };
}
