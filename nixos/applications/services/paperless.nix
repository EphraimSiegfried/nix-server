{ config, ... }:
let
  port = 28981;
  name = "paperless";
in
{
  services.paperless = {
    enable = true;
    dataDir = "${config.state_dir}/${name}";
    mediaDir = "${config.data_dir}/${name}";
    passwordFile = config.sops.secrets."admin-pw".path;
    settings = {
      PAPERLESS_OCR_LANGUAGE = "deu+eng";
      # PAPERLESS_ADMIN_USER = config.admin_name; # does not work
      PAPERLESS_URL = "https://${name}.${config.domain}";
    };
    port = port;
    configureNginx = false;
  };

  # nginx config copied from https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/misc/paperless.nix
  # with small adjustments
  services.nginx = {
    upstreams.paperless.servers."127.0.0.1:${toString port}" = { };
    virtualHosts."${name}.${config.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/".proxyPass = "http://${name}";
        "/static/" = {
          root = config.services.paperless.package;
          extraConfig = ''
            rewrite ^/(.*)$ /lib/paperless-ngx/$1 break;
          '';
        };
        "/ws/status" = {
          proxyPass = "http://${name}";
          proxyWebsockets = true;
        };
      };
    };
  };
}
