{ lib, ... }:
let
  serviceOpts =
    { config, ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
        };
        subdomain = lib.mkOption {
          type = lib.types.str;
          default = lib.toLower config.name;
        };
        port = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        external = lib.mkOption {
          type = lib.types.bool;
          default = false;
        };
        icon = lib.mkOption {
          type = lib.types.str;
          default = lib.toLower config.name;
        };
        description = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        category = lib.mkOption {
          type = lib.types.str;
          default = "Services";
        };
      };
    };
in
{
  flake.modules.nixos.settings =
    { config, ... }:
    with lib.types;
    {
      options = {
        admin = {
          name = lib.mkOption {
            type = str;
          };
          passwordFile = lib.mkOption {
            type = path;
          };
          email = lib.mkOption {
            type = str;
          };
        };
        domain = lib.mkOption {
          type = str;
        };
        baseURL = lib.mkOption {
          type = str;
          default = "https://${config.domain}";
        };
        webServices = lib.mkOption {
          type = attrsOf (submodule serviceOpts);
          default = { };
        };
        locations = lib.mkOption {
          type = attrsOf str;
          default = { };
        };
      };
      config = {
        sops.secrets."admin-pw" = { };
        admin = {
          name = lib.mkDefault "zeus";
          email = lib.mkDefault "ephraim.siegfried@proton.me";
          passwordFile = config.sops.secrets."admin-pw".path;
        };
        domain = lib.mkDefault "qew.ch";
        locations = {
          data = lib.mkDefault "/data";
          media = lib.mkDefault "/media";
          state = lib.mkDefault "/state";
        };
      };
    };
}
