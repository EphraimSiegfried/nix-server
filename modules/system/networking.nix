{
  flake.modules.nixos.networking =
    { config, ... }:
    {
      networking.firewall.enable = true;
      networking.nameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];

      networking.wireguard.interfaces.olly-siegi-vpn = {
        ips = [ "10.100.0.2/24" ];
        privateKeyFile = config.sops.secrets."wireguard/private_key".path;
        peers = [
          {
            publicKey = "8L3Cwpj1cRznCJ8zzV9//6EWQ20NCGAQWAFUO4bK4h8=";
            allowedIPs = [ "10.100.0.1/32" ];
            endpoint = "siegi.internet-box.ch:51820";
            persistentKeepalive = 25;
            dynamicEndpointRefreshSeconds = 30;
          }
        ];
      };

      sops.secrets."wireguard/private_key" = {
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
        restartUnits = [ "wireguard-olly-siegi-vpn.service" ];
      };
    };
}
