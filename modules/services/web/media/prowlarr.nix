{
  flake.modules.nixos.prowlarr =
    { config, ... }:
    let
      port = 9696;
    in
    {
      webServices.prowlarr = {
        name = "Prowlarr";
        inherit port;
        description = "Indexer manager for Radarr, Sonarr, and others";
        category = "Media";
      };

      nixarr.prowlarr = {
        enable = true;
        openFirewall = true;
      };
    };
}
