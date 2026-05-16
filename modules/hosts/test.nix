{ inputs, self, ... }:
let
  hostname = "test";
in
{
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
          programs.bash.shellAliases.off = "poweroff";
          sops.defaultSopsFile = "${inputs.self}/secrets/secrets-test.yaml";
          sops.age.keyFile = "/var/lib/age/test-key.txt";

          services.getty.autologinUser = "root";
          virtualisation.vmVariant = {
            virtualisation.graphics = false;
            virtualisation.sharedDirectories.secrets = {
              source = "${inputs.self}/secrets";
              target = "/mnt/secrets";
            };
          };

          systemd.tmpfiles.rules = [
            "C /var/lib/age/test-key.txt - - - - /mnt/secrets/test-key.txt"
          ];
        }
      ];
    };
  };
}
