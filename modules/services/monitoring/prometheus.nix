{
  flake.modules.nixos.prometheus =
    { config, ... }:
    {
      services.prometheus = {
        enable = true;
        port = 9001;
        remoteWrite = [
          {
            url = "http://10.100.0.1:9001/api/v1/write";
          }
        ];
        exporters = {
          node = {
            enable = true;
            enabledCollectors = [ "systemd" ];
            port = 9002;
          };
          smartctl = {
            enable = true;
            port = 9003;
            devices = [
              "/dev/nvme0n1"
              "/dev/sda"
            ];
          };
        };
        scrapeConfigs = [
          {
            job_name = "node_exporter";
            scrape_interval = "15s";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
                labels = {
                  instance = config.networking.hostName;
                };
              }
            ];
          }
          {
            job_name = "smartctl_exporter";
            scrape_interval = "60s";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.smartctl.port}" ];
                labels = {
                  instance = config.networking.hostName;
                };
              }
            ];
          }
        ];
      };
    };
}
