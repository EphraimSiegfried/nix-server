{ pkgs, config, ... }:
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
      uiPort = 9091; # standard port for transmission
    };
  };
  systemd.services.wg.serviceConfig = {
    # Hack to avoid a race condition where wg tried to read the wireguard entpoint 
    # `nl3.vpn.airdns.org` before the network is up and running.
    # This is not a proper fix but good enough for now.
    ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
  };
}
