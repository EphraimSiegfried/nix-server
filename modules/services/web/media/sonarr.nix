{
  flake.modules.nixos.sonarr =
    { config, ... }:
    let
      port = 8989;
    in
    {
      webServices.sonarr = {
        name = "Sonarr";
        inherit port;
        description = "Automated TV show downloader and organizer";
        category = "Media";
      };

      nixarr.sonarr = {
        enable = true;
        openFirewall = true;
      };
    };
}
