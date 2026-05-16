{ inputs, ... }:
{
  flake.modules.nixos.libix =
    { config, ... }:
    let
      port = 9399;
    in
    {
      imports = [
        inputs.libix.nixosModules.default
      ];
      nixpkgs.overlays = [ inputs.libix.overlays.default ];

      webServices.libix = {
        name = "Libix";
        inherit port;
        description = "Audiobook search and download manager";
        category = "Media";
      };

      services.libix = {
        enable = true;
        extraGroups = [ "media" ];
        downloadDir = "${config.locations.media}/torrents";
        settings = {
          server = {
            inherit port;
            secret_key_file = config.sops.secrets."libix/api_key".path;
          };
          auth.initial_admin.username = config.admin.name;
          library.path = "${config.locations.media}/library/audiobooks";
          transmission = {
            url = "http://localhost:9091/transmission/rpc";
            download_dir = "${config.locations.media}/torrents";
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
    };
}
