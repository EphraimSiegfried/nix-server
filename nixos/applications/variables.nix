{ lib, ... }:
{
  options =
    with lib;
    with types;
    {
      domain = mkOption { type = str; };
      data_dir = mkOption { type = str; };
      state_dir = mkOption { type = str; };
      email = mkOption { type = str; };
      admin_name = mkOption { type = str; };
    };
  config = {
    domain = "qew.ch";
    data_dir = "/data";
    state_dir = "/state";
    email = "ephraim.siegfried@hotmail.com";
    admin_name = "zeus"; # for default admin user names
  };
}
