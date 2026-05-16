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
      systemd.services.wg.serviceConfig = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      };
    };
}
