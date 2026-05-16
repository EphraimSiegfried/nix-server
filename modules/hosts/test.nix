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
        (self.factory.caddy { useTLS = false; })
        {
          programs.bash.shellAliases.off = "poweroff";
          sops.defaultSopsFile = "${inputs.self}/secrets/secrets-test.yaml";
          sops.age.keyFile = "/var/lib/age/test-key.txt";
          sops.age.sshKeyPaths = [ ];
          sops.gnupg.sshKeyPaths = [ ];

          system.activationScripts.setup-test-key = {
            deps = [ "specialfs" ];
            text = ''
              mkdir -p /var/lib/age
              cp ${inputs.self}/secrets/test-key.txt /var/lib/age/test-key.txt
              chmod 0640 /var/lib/age/test-key.txt
            '';
          };

          domain = "localhost";
          baseURL = "https://localhost:8443";
          services.getty.autologinUser = "root";
          virtualisation.vmVariant = {
            virtualisation.graphics = false;
            virtualisation.memorySize = 4096;
            virtualisation.forwardPorts = [
              {
                from = "host";
                host.port = 8080;
                guest.port = 80;
              }
              {
                from = "host";
                host.port = 8443;
                guest.port = 443;
              }
            ];
          };
        }
      ];
    };
  };
}
