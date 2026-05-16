{
  flake.modules.nixos.mealie =
    { config, ... }:
    let
      subdomain = "mealie";
      port = 9281;
    in
    {
      webServices.mealie = {
        inherit subdomain port;
        icon = "mealie";
        description = "Recipe management app";
        category = "Cloud";
      };

      services.mealie = {
        enable = true;
        inherit port;
        settings = {
          BASE_URL = "${subdomain}.${config.domain}";
        };
      };
    };
}
