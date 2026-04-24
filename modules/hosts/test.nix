{ inputs, self, ... }:
let
  hostname = "test";
in
{
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];

  perSystem =
    { self', ... }:
    {
      packages.default = inputs.self.nixosConfigurations.${hostname}.config.system.build.vm;
    };
  flake.nixosConfigurations = {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = with inputs.self.modules.nixos; [
        siegi
        zenoli
        nix
        {
          system.stateVersion = "25.11";
          networking.hostName = hostname;

          # TODO: Please remove once done
          services.getty.autologinUser = "root";

          virtualisation.vmVariant.virtualisation.graphics = false;
        }
      ];
    };
  };
}
