{ pkgs, ... }:
let
  port = 51820;
in
{
  networking.firewall.allowedTCPPorts = [ port ];
  services.mysql = {
    enable = true;
    package = pkgs.mariadb_114;
    # default location
    dataDir = "/var/lib/mysql";
    settings = {
      mysqld = {
        inherit port;
        bind_address = "0.0.0.0";
      };
    };
    initialDatabases = [
      { name = "dbs"; }
    ];
  };

}
