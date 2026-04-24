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
      packages.${hostname} = self.nixosConfigurations.${hostname}.config.system.build.vm;
      packages.default = self'.packages.${hostname};

    };
  flake.nixosConfigurations = {
    ${hostname} = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = with self.modules.nixos; [
        ares
        {
          services.getty.autologinUser = "root";
          virtualisation.vmVariant.virtualisation.graphics = false;
          programs.bash.shellAliases.off = "poweroff";
        }
      ];
    };
  };
}
