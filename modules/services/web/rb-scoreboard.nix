{ inputs, ... }:
{
  flake.modules.nixos.rb-scoreboard =
    { config, ... }:
    let
      port = 9400;
    in
    {
      imports = [
        inputs.rb-scoreboard.nixosModules.default
      ];
      nixpkgs.overlays = [ inputs.rb-scoreboard.overlays.default ];

      webServices.rb-scoreboard = {
        name = "RB Scoreboard";
        subdomain = "rb";
        inherit port;
        description = "Rugby scoreboard";
        category = "Sports";
      };

      sops.secrets."rb-scoreboard/sm_api_key" = {
        owner = "rb-scoreboard";
      };
      sops.secrets."rb-scoreboard/jwt_secret" = {
        owner = "rb-scoreboard";
      };
      sops.secrets."rb-scoreboard/admin_api_key" = {
        owner = "rb-scoreboard";
      };

      sops.templates."rb-scoreboard.env" = {
        owner = "rb-scoreboard";
        content = ''
          SM_API_KEY=${config.sops.placeholder."rb-scoreboard/sm_api_key"}
          JWT_SECRET=${config.sops.placeholder."rb-scoreboard/jwt_secret"}
          ADMIN_API_KEY=${config.sops.placeholder."rb-scoreboard/admin_api_key"}
        '';
      };

      services.rb-scoreboard = {
        enable = true;
        dataDir = "${config.locations.data}/rb-scoreboard";
        inherit port;
        environmentFile = config.sops.templates."rb-scoreboard.env".path;
        extraEnv = {
          SM_SEASON_ID = "26618"; # WC2026
        };
      };
    };
}
