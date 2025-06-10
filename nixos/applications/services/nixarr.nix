{ config, ... }:
{

  sops.secrets."wg-conf" = { };
  nixarr = {
    enable = true;
    mediaDir = "${config.data_dir}/media";
    stateDir = "${config.data_dir}/media/.state/nixarr";

    vpn = {
      enable = true;
      wgConf = config.sops.secrets."wg-conf".path;
      vpnTestService.enable = true;
      vpnTestService.port = 2819;
    };

    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    transmission = {
      enable = true;
      vpn.enable = true;
      openFirewall = true;
      peerPort = 2819;
      flood.enable = true;
    };

    prowlarr.enable = true;
    prowlarr.openFirewall = true;
    radarr.enable = true;
    radarr.openFirewall = true;
    sonarr.enable = true;
    sonarr.openFirewall = true;
  };

  services.nginx.virtualHosts."jelly.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8096";
      recommendedProxySettings = true;
    };
  };

  services.nginx.virtualHosts."prowlarr.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9696";
      recommendedProxySettings = true;
    };
  };
  services.nginx.virtualHosts."radarr.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:7878";
      recommendedProxySettings = true;
    };
  };
  services.nginx.virtualHosts."sonarr.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8989";
      recommendedProxySettings = true;
    };
  };
}
