{
  flake.modules.nixos.siegi =
    { pkgs, ... }:
    {
      nix.settings.trusted-users = [
        "root"
        "siegi"
      ];

      users.users = {
        siegi = {
          isNormalUser = true;
          description = "Ephraim";
          extraGroups = [
            "networkmanager"
            "wheel"
            "docker"
          ];
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM56oJGPCghkpixf0EET44ehH5K2VyCzf+NLfPSCxnq1 siegi@thymian"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGdANrCkeXTrZha/w3pvg/vCZWmuRsy7cI6PmgVfWH8c siegi@blinkybill"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4/dxajByIB9PaameTee+vbKuWtE6/XJ3vg4JjwfBpl siegi@oz"
          ];
        };
      };
    };
}
