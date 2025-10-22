{ pkgs, config, ... }:
let
  subdomain = "cloud";
in
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = "${subdomain}.${config.domain}";
    home = "${config.data_dir}/nextcloud";
    maxUploadSize = "16G";
    https = true;
    configureRedis = true;
    database.createLocally = true;
    config = {
      adminuser = config.admin_name;
      adminpassFile = config.sops.secrets."admin-pw".path;

      dbtype = "pgsql";
      dbname = "nextcloud";
      dbuser = "nextcloud";
    };
  };

  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
