{ config, ... }:
let
  port = 9093;
  subdomain = "am";
in
{
  services.prometheus = {
    alertmanager = {
      enable = true;
      port = port;
      webExternalUrl = "https://${subdomain}.${config.domain}";
      openFirewall = true;
      checkConfig = true;
      configText = builtins.readFile ./alertmanager.yml;
    };
    ruleFiles = [ ./alerts.yml ];
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
