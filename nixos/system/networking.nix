{ config, ... }:
{
  networking = {
    hostName = "ares";
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        81
        443
      ];
    };
  };
  networking.wireguard.interfaces.olly-siegi-vpn = {
    ips = [ "10.100.0.2/24" ];

    privateKeyFile = config.sops.secrets."wireguard/private_key".path;

    peers = [
      {
        publicKey = "8L3Cwpj1cRznCJ8zzV9//6EWQ20NCGAQWAFUO4bK4h8=";
        allowedIPs = [ "10.100.0.1/32" ];
        endpoint = "siegi.internet-box.ch:51820";
        persistentKeepalive = 25;
      }
    ];
  };
  sops.secrets."wireguard/private_key" = {
    mode = "640";
    owner = "systemd-network";
    group = "systemd-network";
  };
}
