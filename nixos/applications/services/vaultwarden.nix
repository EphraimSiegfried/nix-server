{ config, ... }:
let
  subdomain = "vw";
  port = 8002;
in
{
  services.vaultwarden = {
    enable = true;
    backupDir = config.data_dir + "/vaultwarden";
    config = {
      DOMAIN = " https://${subdomain}.${config.domain}";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = port;
      ROCKET_LOG = "critical";
    };
  };

  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString 8002}";
      recommendedProxySettings = true;
    };
  };
}
