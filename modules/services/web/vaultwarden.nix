{
  flake.modules.nixos.vaultwarden =
    { config, ... }:
    let
      subdomain = "vw";
      port = 8002;
    in
    {
      webServices.vaultwarden = {
        name = "Vaultwarden";
        subdomain = subdomain;
        inherit port;
        description = "Password manager compatible with Bitwarden clients";
        category = "Cloud";
      };

      services.vaultwarden = {
        enable = true;
        backupDir = config.locations.data + "/vaultwarden";
        config = {
          DOMAIN = "https://${subdomain}.${config.domain}";
          SIGNUPS_ALLOWED = false;
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = port;
          ROCKET_LOG = "critical";
        };
      };
    };
}
