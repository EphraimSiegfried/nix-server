{
  flake.modules.nixos.paperless =
    { config, ... }:
    let
      port = 28981;
    in
    {
      webServices.paperless = {
        name = "Paperless";
        icon = "paperless-ngx";
        inherit port;
        description = "Document management system that transforms physical documents into a searchable online archive";
        category = "Cloud";
      };

      services.paperless = {
        enable = true;
        inherit port;
        dataDir = "${config.locations.state}/paperless";
        mediaDir = "${config.locations.data}/paperless";
        passwordFile = config.admin.passwordFile;
        settings = {
          PAPERLESS_OCR_LANGUAGE = "deu+eng";
          PAPERLESS_URL = "https://${config.webServices.paperless.subdomain}.${config.domain}";
        };
      };
    };
}
