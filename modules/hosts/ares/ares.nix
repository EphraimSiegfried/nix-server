{ inputs, self, ... }:
let
  hostname = "ares";
in
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  flake.modules.nixos.${hostname} = {
    imports = with self.modules.nixos; [
      ./_hardware-configuration.nix
      bootloader
      nix
      networking
      secrets
      settings
      ssh
      siegi
      zenoli
      {
        system.stateVersion = "25.11";
        networking.hostName = hostname;
        time.timeZone = "Europe/Zurich";
      }
    ];
  };
  flake.nixosConfigurations = {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = with self.modules.nixos; [
        ares
        (self.factory.caddy { })
      ];
    };
  };
}
