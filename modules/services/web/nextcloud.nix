{
  flake.modules.nixos.nextcloud =
    {
      pkgs,
      config,
      ...
    }:
    let
      subdomain = "cloud";
      port = 8001;
    in
    {
      webServices.nextcloud = {
        name = "Nextcloud";
        subdomain = subdomain;
        inherit port;
        description = "File storage and more";
        category = "Cloud";
      };

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud32;
        hostName = "${subdomain}.${config.domain}";
        home = "${config.locations.data}/nextcloud";
        maxUploadSize = "16G";
        https = true;
        configureRedis = true;
        database.createLocally = true;
        config = {
          adminuser = config.admin.name;
          adminpassFile = config.admin.passwordFile;
          dbtype = "pgsql";
          dbname = "nextcloud";
          dbuser = "nextcloud";
        };
      };

      services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
        listen = [
          {
            addr = "127.0.0.1";
            inherit port;
          }
        ];
      };
    };
}
