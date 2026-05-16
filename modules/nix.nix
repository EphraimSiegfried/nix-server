{ inputs, ... }:
{
  flake.modules.nixos.nix =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      nix = {
        settings = {
          experimental-features = "nix-command flakes pipe-operators";
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
        registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
        nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
      };

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; [
        btrfs-progs
        curl
        git
        lf
        man-pages
        neovim
      ];
    };
}
