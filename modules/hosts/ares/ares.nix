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
      audiobookshelf
      bazarr
      docuseal
      external
      homepage
      jellyfin
      jellyseerr
      libix
      media
      mealie
      nextcloud
      prowlarr
      radarr
      sonarr
      transmission
      paperless
      prometheus
      promtail
      vaultwarden
      nix
      networking
      secrets
      settings
      ssh
      siegi
      zenoli
      {
        system.stateVersion = "23.11";
        networking.hostName = hostname;
        time.timeZone = "Europe/Zurich";
        i18n.defaultLocale = "en_US.UTF-8";
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
