{ inputs, config, ... }:
let
  port = 8129;
  subdomain = "bindery";
in
{
  imports = [
    { nixpkgs.overlays = [ inputs.nur-ephraim.overlays.default ]; }
    inputs.nur-ephraim.nixosModules.bindery
  ];

  users.users.bindery.extraGroups = [ "media" ];

  services.bindery = {
    enable = true;
    downloadDir = "/media/torrents";
    libraryDir = "/media/library/books";
    audiobookDir = "/media/library/audiobooks";
    port = port;
  };

  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
