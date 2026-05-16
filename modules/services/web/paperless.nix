{
  flake.modules.nixos.paperless =
    { config, ... }:
    let
      subdomain = "paperless";
      port = 28981;
    in
    {
      webServices.paperless = {
        inherit subdomain port;
        icon = "paperless-ngx";
        description = "Document management system that transforms physical documents into a searchable online archive";
        category = "Cloud";
      };

      services.paperless = {
        enable = true;
        inherit port;
        dataDir = "${config.locations.state}/${subdomain}";
        mediaDir = "${config.locations.data}/${subdomain}";
        passwordFile = config.admin.passwordFile;
        settings = {
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_URL = "https://${subdomain}.${config.domain}";
        };
      };
    };
}
