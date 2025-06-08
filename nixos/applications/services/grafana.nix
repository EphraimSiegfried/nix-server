{ config, ... }:
{
  sops.secrets."admin-pw" = {
    owner = "grafana";
  }; # TODO: move to better place

  services.grafana = {
    enable = true;
    # dataDir = "${config.data_dir}/monitoring/grafana";
    settings = {
      server = {
        domain = "grafana.${config.domain}";
        http_port = 2342;
        addr = "127.0.0.1";
      };
      security = {
        admin_user = config.admin_name;
        admin_email = config.email;
        admin_password = "$__file{${config.sops.secrets."admin-pw".path}}";
      };
    };

    provision = {
      enable = true;
      datasources = {
        settings = {
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
              isDefault = true;
            }
          ];
        };
      };
      dashboards.settings = {
        providers = [
          {
            name = "Node Exporter";
            options.path = ./dashboards/node-exporter-full_rev1.json;
          }
        ];
      };
    };
  };

  services.nginx.virtualHosts."grafana.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
