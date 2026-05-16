{
  flake.modules.nixos.jellyseerr =
    { config, ... }:
    let
      subdomain = "js";
      port = 9899;
    in
    {
      webServices.jellyseerr = {
        name = "Jellyseerr";
        subdomain = subdomain;
        inherit port;
        description = "Request interface for movies and shows in Jellyfin";
        category = "Media";
      };

      services.jellyseerr = {
        enable = true;
        openFirewall = true;
        inherit port;
      };
    };
}
