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
    mediaDir = "${config.data_dir}/media";
    stateDir = "${config.data_dir}/media/.state/nixarr";
  };
}
