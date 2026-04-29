{ inputs, config, ... }:
{
  imports = [ inputs.libix.nixosModules.default ];
  nixpkgs.overlays = [ inputs.libix.overlays.default ];

  services.libix = {
    enable = true;
    extraGroups = [ "media" ];
    downloadDir = "${config.media_dir}/torrents";
    settings = {
      server = {
        port = 9399;
        secret_key_file = config.sops.secrets."libix/api_key".path;
      };
      auth.initial_admin.username = "zeus";
      library.path = "${config.media_dir}/library/audiobooks";
      transmission = {
        url = "http://localhost:9091/transmission/rpc";
        download_dir = "${config.media_dir}/torrents";
      };
      prowlarr = {
        url = "http://localhost:9696";
        api_key_file = config.sops.secrets."prowlarr/api_key".path;
      };
    };
  };
  sops.secrets."prowlarr/api_key" = {
    owner = "libix";
  };
  sops.secrets."libix/api_key" = {
    owner = "libix";
  };

  services.nginx.virtualHosts."libix.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.libix.settings.server.port}";
      recommendedProxySettings = true;
    };
  };
}
