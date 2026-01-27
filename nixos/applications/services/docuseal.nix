{ config, ... }:
let
  subdomain = "docuseal";
  port = 3981;
in
{
  sops.secrets."docuseal/secret_key" = {
    # TODO: the only owner of this secret should be the docuseal user
    # unfortunately this user is dynamically created as seen in:
    # https://github.com/NixOS/nixpkgs/blob/ed142ab1b3a092c4d149245d0c4126a5d7ea00b0/nixos/modules/services/web-apps/docuseal.nix#L135
    # this means that we cannot reference that user here
    # this issue must be resolved with a PR to nixpkgs
    mode = "0444";
  };

  services.docuseal = {
    enable = true;
    port = port;
    extraConfig = {
      HOST = "${subdomain}.${config.domain}";
    };
    secretKeyBaseFile = config.sops.secrets."docuseal/secret_key".path;
  };

  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
      proxyWebsockets = true;
    };
  };
}
