{ inputs, ... }:
{
  flake.modules.nixos.media =
    { config, ... }:
    {
      imports = [
        inputs.nixarr.nixosModules.default
      ];

      nixarr = {
        enable = true;
        mediaDir = config.locations.media;
        stateDir = "${config.locations.data}/media/.state/nixarr";
      };
    };
}
