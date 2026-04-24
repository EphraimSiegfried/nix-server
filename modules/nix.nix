{
  flake.modules.nixos.nix =
    { config, ... }:
    {
      nix = {
        settings = {
          experimental-features = "nix-command flakes";
          # disable global registry
          flake-registry = "";
          # Workaround for https://github.com/NixOS/nix/issues/9574
          nix-path = config.nix.nixPath;
        };

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
        channel.enable = false;
      };

      nixpkgs.config.allowUnfree = true;

    };
}
