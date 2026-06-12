{
  flake.modules.nixos.transmission =
    { config, pkgs, ... }:
    {
      sops.secrets."wg-conf" = { };
      nixarr = {
        vpn = {
          enable = true;
          vpnTestService.enable = true;
          wgConf = config.sops.secrets."wg-conf".path;
        };

        transmission = {
          enable = true;
          vpn.enable = true;
          openFirewall = true;
          peerPort = 2819;
          flood.enable = true;
          uiPort = 9091;
          extraSettings = {
            ratio-limit-enabled = true;
            ratio-limit = 0;
          };
        };
      };
      systemd.services.wg = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "10s";
        };
        # Start transmission after wg comes up
        postStart = "systemctl start --no-block transmission.service || true";
      };
      systemd.services.transmission = {
        after = [ "wg.service" ];
        requires = [ "wg.service" ];
      };
      # Ensure transmission starts after wg recovers from failure
      systemd.services.transmission-kickstart = {
        after = [ "wg.service" ];
        requires = [ "wg.service" ];
        wantedBy = [ "wg.service" ];
        serviceConfig.Type = "oneshot";
        script = "systemctl reset-failed transmission.service; systemctl start transmission.service";
      };
    };
}
