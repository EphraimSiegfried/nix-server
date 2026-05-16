{
  flake.modules.nixos.docuseal =
    { config, ... }:
    let
      subdomain = "docuseal";
      port = 3981;
    in
    {
      webServices.docuseal = {
        inherit subdomain port;
        icon = "docuseal";
        description = "Sign PDF";
        category = "Cloud";
      };

      sops.secrets."docuseal/secret_key" = {
        mode = "0444";
      };

      services.docuseal = {
        enable = true;
        inherit port;
        extraConfig = {
          HOST = "${subdomain}.${config.domain}";
        };
        secretKeyBaseFile = config.sops.secrets."docuseal/secret_key".path;
      };
    };
}
