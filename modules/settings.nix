{ lib, ... }:
let
  adminOpts =
    { ... }:
    {
      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = "zeus";
        };
        email = lib.mkOption {
          type = lib.types.str;
          default = "ephraim.siegfried@proton.me";
        };
      };
    };
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
  flake.modules.nixos.config = {
    options = {
      admin = lib.mkOption {
        type = lib.types.submodule adminOpts;
        default = { };
      };
      domain = lib.mkOption {
        type = lib.types.str;
        default = "qew.ch";
      };
      myServices = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule serviceOpts);
        default = { };
      };
    };
  };
}
