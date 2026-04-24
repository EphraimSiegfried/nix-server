{ inputs, ... }:
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  flake.nixosConfigurations =
    let
      hostname = "ares";
    in
    {
      ${hostname} = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = with inputs.self.modules.nixos; [
          ./_hardware-configuration.nix
          siegi
          zenoli
          ssh-server
          {
            system.stateVersion = "25.11";
            networking.hostName = hostname;
          }
        ];
      };
    };
}
