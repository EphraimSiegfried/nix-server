{
  flake.modules.nixos.bazarr =
    { config, ... }:
    let
      port = 6767;
    in
    {
      webServices.bazarr = {
        name = "Bazarr";
        inherit port;
        description = "Subtitle downloader and manager for Radarr and Sonarr";
        category = "Media";
      };

      nixarr.bazarr = {
        enable = true;
        openFirewall = true;
      };
    };
}
