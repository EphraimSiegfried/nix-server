{
  flake.modules.nixos.caddy =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      makeVirtualHost = _name: service: {
        "${service.subdomain}.${config.domain}" = {
          extraConfig = ''
            reverse_proxy http://localhost:${toString service.port}
          '';
        };
      };
    in
    {
      services.caddy = {
        enable = true;
        package = pkgs.caddy.withPlugins {
          plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
          hash = "sha256-4WF7tIx8d6O/Bd0q9GhMch8lS3nlR5N3Zg4ApA3hrKw=";
        };
        email = config.primaryUser.email;
        globalConfig = ''
          acme_dns cloudflare {env.CLOUDFLARE_API_TOKEN}
          skip_install_trust
        '';
        environmentFile = config.sops.templates."caddy.env".path;
        virtualHosts = lib.mkMerge (lib.mapAttrsToList makeVirtualHost config.myServices);
      };

      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      systemd.services.caddy.serviceConfig.Path = [ pkgs.nssTools ];

      sops.secrets."cloudflare/api_token" = {
        owner = config.systemd.services.caddy.serviceConfig.User;
      };
      sops.templates."caddy.env" = {
        owner = config.systemd.services.caddy.serviceConfig.User;
        content = ''
          CLOUDFLARE_API_TOKEN=${config.sops.placeholder."cloudflare/api_token"}
        '';
      };
    };
}
