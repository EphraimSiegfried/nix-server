{ lib, ... }:
let
  serviceOpts =
    { ... }:
    {
      options = {
        subdomain = lib.mkOption {
          type = lib.types.str;
        };
        port = lib.mkOption {
          type = lib.types.int;
        };
      };
    };
in
{
  flake.modules.nixos.settings = with lib.types; {
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
      myServices = lib.mkOption {
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
