{ config, ... }:
{
  sops.secrets."wg-conf" = { };
  nixarr = {
    vpn = {
      enable = true;
      wgConf = config.sops.secrets."wg-conf".path;
    };

    transmission = {
      enable = true;
      vpn.enable = true;
      openFirewall = true;
      peerPort = 2819;
      flood.enable = true;
    };
  };
}
