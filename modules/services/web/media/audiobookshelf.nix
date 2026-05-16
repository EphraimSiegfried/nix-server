{
  flake.modules.nixos.audiobookshelf =
    { config, ... }:
    let
      port = 9193;
    in
    {
      webServices.audiobookshelf = {
        name = "Audiobookshelf";
        subdomain = "abs";
        inherit port;
        description = "Self-hosted audiobook and podcast server";
        category = "Media";
      };

      nixarr.audiobookshelf = {
        enable = true;
        openFirewall = true;
        inherit port;
      };
    };
}
