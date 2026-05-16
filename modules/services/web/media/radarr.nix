{
  flake.modules.nixos.radarr =
    { config, ... }:
    let
      port = 7878;
    in
    {
      webServices.radarr = {
        name = "Radarr";
        inherit port;
        description = "Automated movie downloader and organizer";
        category = "Media";
      };

      nixarr.radarr = {
        enable = true;
        openFirewall = true;
      };
    };
}
