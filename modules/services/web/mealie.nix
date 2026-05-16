{
  flake.modules.nixos.mealie =
    { config, ... }:
    let
      port = 9281;
    in
    {
      webServices.mealie = {
        name = "Mealie";
        inherit port;
        description = "Recipe management app";
        category = "Cloud";
      };

      services.mealie = {
        enable = true;
        inherit port;
        settings = {
          BASE_URL = "${config.webServices.mealie.subdomain}.${config.domain}";
        };
      };
    };
}
