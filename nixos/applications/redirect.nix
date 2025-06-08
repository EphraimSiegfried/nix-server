{ config, ... }:
{
  # Redirections to zeus server
  services.nginx.virtualHosts = {
    "notfound.${config.domain}" = {
      useACMEHost = config.domain;
      forceSSL = true;
      root = ./notfound;
    };
    "_" = {
      globalRedirect = "notfound.${config.domain}";
    };

    # redirections to another server in the local network
    # "*.qew.ch" = {
    #   locations."/" = {
    #     proxyPass = "http://zeus:80";
    #     recommendedProxySettings = true;
    #   };
    # };
  };
}
