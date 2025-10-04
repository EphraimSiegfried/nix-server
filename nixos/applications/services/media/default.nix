{ config, ... }:
{
  imports = [
    ./transmission.nix
    ./radarr.nix
    ./sonarr.nix
    ./prowlarr.nix
    ./jellyfin.nix
    ./jellyseerr.nix
    ./bazarr.nix
  ];

  nixarr = {
    enable = true;
    mediaDir = "${config.media_dir}";
    stateDir = "${config.data_dir}/media/.state/nixarr";
  };
}
