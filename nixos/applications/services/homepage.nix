{
  pkgs,
  lib,
  config,
  ...
}:
{
  services.homepage-dashboard = {
    enable = true;
    # NOTE: This can be removed once the path bug is fixed upstream:
    # https://github.com/NixOS/nixpkgs/pull/453314
    package = pkgs.homepage-dashboard.overrideAttrs (oldAttrs: rec {
      installPhase = ''
        runHook preInstall

        mkdir -p $out/{bin,share}
        cp -r .next/standalone $out/share/homepage/
        cp -r public $out/share/homepage/public
        chmod +x $out/share/homepage/server.js

        mkdir -p $out/share/homepage/.next
        cp -r .next/static $out/share/homepage/.next/static

        makeWrapper "${lib.getExe pkgs.nodejs}" $out/bin/homepage \
          --set-default PORT 3000 \
          --set-default HOMEPAGE_CONFIG_DIR /var/lib/homepage-dashboard \
          --set-default NIXPKGS_HOMEPAGE_CACHE_DIR /var/cache/homepage-dashboard \
          --add-flags "$out/share/homepage/server.js" \
          --prefix : PATH "${lib.makeBinPath [ pkgs.unixtools.ping ]}"

        runHook postInstall
      '';
    });

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
          {
            "Bazarr" = {
              href = "https://bazarr.${config.domain}";
              icon = "bazarr";
              description = "Subtitle downloader and manager for Radarr and Sonarr.";
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
          {
            "Paperless" = {
              href = "https://paperless.${config.domain}";
              icon = "paperless-ngx";
              description = "Document management system that transforms physical documents into a searchable online archive";
            };

          }
          {
            "Mealie" = {
              href = "https://mealie.${config.domain}";
              icon = "mealie";
              description = "Recipe management app";
            };

            "Docuseal" = {
              href = "https://docuseal.${config.domain}";
              icon = "docuseal";
              description = "Sign PDF";
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
          disk = [
            "/"
            "/media"
          ];
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
