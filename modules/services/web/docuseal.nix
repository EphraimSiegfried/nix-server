{
  flake.modules.nixos.docuseal =
    { config, ... }:
    let
      port = 3981;
    in
    {
      webServices.docuseal = {
        name = "Docuseal";
        inherit port;
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
          HOST = "${config.webServices.docuseal.subdomain}.${config.domain}";
        };
        secretKeyBaseFile = config.sops.secrets."docuseal/secret_key".path;
      };
    };
}
