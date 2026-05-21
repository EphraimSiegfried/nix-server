{
  config.flake.factory.caddy =
    { useTLS ? true }:
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      mkHostname = svc:
        let
          host =
            if svc.subdomain == "@" then
              config.domain
            else
              "${svc.subdomain}.${config.domain}";
        in
        if useTLS then host else "http://${host}";
      mkVhost = _name: svc: {
        "${mkHostname svc}" = {
          extraConfig = "reverse_proxy http://localhost:${toString svc.port}";
        };
      };
    in
    lib.mkMerge [
      {
        networking.firewall.allowedTCPPorts = [
          80
          443
        ];
        services.caddy = {
          enable = true;
          virtualHosts = lib.mkMerge (
            lib.mapAttrsToList mkVhost config.webServices
            ++ [
              {
                "${if useTLS then "" else "http://"}*.${config.domain}" = {
                  extraConfig = ''
                      root * ${./web/notfound}
                      try_files {path} /index.html
                      file_server
                    '';
                };
              }
            ]
          );
        };
      }
      (lib.mkIf useTLS {
        services.caddy = {
          package = pkgs.caddy.withPlugins {
            plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
            hash = "sha256-J89UH8YgEU/uUDtmRuoGkPzIcQrbbWk+k06gqj0t8ho=";
          };
          email = config.admin.email;
          globalConfig = ''
            acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
            skip_install_trust
          '';
          environmentFile = config.sops.templates."caddy.env".path;
        };

        sops.secrets."cloudflare/api-key" = {
          owner = config.systemd.services.caddy.serviceConfig.User;
        };
        sops.templates."caddy.env" = {
          owner = config.systemd.services.caddy.serviceConfig.User;
          content = ''
            CLOUDFLARE_API_TOKEN=${config.sops.placeholder."cloudflare/api-key"}
          '';
        };
      })
    ];
}
