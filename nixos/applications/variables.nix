{ lib, ... }:
{
  options =
    with lib;
    with types;
    {
      domain = mkOption { type = str; };
      data_dir = mkOption { type = str; };
      media_dir = mkOption { type = str; };
      state_dir = mkOption { type = str; };
      email = mkOption { type = str; };
      admin_name = mkOption { type = str; };
      bot.mail = mkOption { type = str; };
      bot.smtp_server = mkOption { type = str; };
    };
  config = {
    domain = "qew.ch";
    data_dir = "/data";
    media_dir = "/media";
    state_dir = "/state";
    email = "ephraim.siegfried@hotmail.com";
    admin_name = "zeus"; # for default admin user names
    bot = {
      mail = "bot@qew.ch";
      smtp_server = "smtp.protonmail.ch:587";
    };
  };
}
