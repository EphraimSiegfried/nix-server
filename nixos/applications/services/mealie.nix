{ config, ... }: {
  services.mealie = {
    enable = true;
    port = 9281;
    settings = {
      BASE_URL = "mealie.${config.domain}";
    };
  };
  services.nginx.virtualHosts."mealie.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.mealie.port}";
      recommendedProxySettings = true;
    };
  };
}
