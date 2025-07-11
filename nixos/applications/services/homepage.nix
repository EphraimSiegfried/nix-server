{ config, ... }:
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    allowedHosts = config.domain;
    settings = {
      title = "Zenolium";
      description = "Welcome to Zenolium";
      background = {
        image = "https://preview.redd.it/space-wallpapers-4k-3840-2160-v0-xlbdzh75m88f1.jpg?width=1080&crop=smart&auto=webp&s=325d1f2a3c59d23ecbbdf6ad10000299b11b94b9";
        blur = "md";
      };
      layout = {
        Media = {
          style = "row";
          columns = 5;

        };
      };
    };
    services = [
      {
        "Media" = [
          {
            "Jellyfin" = {
              href = "https://jelly.${config.domain}";
              icon = "jellyfin";
              description = "Media server for streaming movies, shows, and music.";
            };
          }
          {
            "Jellyseerr" = {
              href = "https://js.${config.domain}";
              icon = "jellyseerr";
              description = "Request interface for movies and shows in Jellyfin.";
            };
          }
          {
            "Radarr" = {
              href = "https://radarr.${config.domain}";
              icon = "radarr";
              description = "Automated movie downloader and organizer.";
            };
          }
          {
            "Sonarr" = {
              href = "https://sonarr.${config.domain}";
              icon = "sonarr";
              description = "Automated TV show downloader and organizer.";
            };
          }
          {
            "Prowlarr" = {
              href = "https://prowlarr.${config.domain}";
              icon = "prowlarr";
              description = "Indexer manager for Radarr, Sonarr, and others.";
            };
          }
        ];

      }
      {

        "Cloud" = [
          {
            "Nextcloud" = {
              href = "https://cloud.${config.domain}";
              icon = "nextcloud";
              description = "File storage and more";
            };
          }
          {
            "Vaultwarden" = {
              href = "https://vw.${config.domain}";
              icon = "vaultwarden";
              description = "Password manager compatible with Bitwarden clients";

            };
          }
        ];

      }
      {
        "Monitoring" = [
          {
            "Grafana" = {
              href = "https://grafana.${config.domain}";
              icon = "grafana";
              description = "Dashboard tool for visualizing metrics and logs.";
            };
          }
        ];
      }

    ];
    widgets = [
      {
        resources = {
          cpu = true;
          disk = "/";
          memory = true;
        };
      }
    ];
  };
  services.nginx.virtualHosts."${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.homepage-dashboard.listenPort}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };

}
