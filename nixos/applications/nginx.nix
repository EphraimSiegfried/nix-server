{ pkgs, config, ... }:
{
  imports = [
    ./redirect.nix
    ./variables.nix
    ./services
  ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
  };

  sops.secrets."cloudflare/api-key" = { };
  sops.templates."cloudflare.env".content = ''
    CLOUDFLARE_EMAIL=${config.email}
    CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder."cloudflare/api-key"}
  '';

  security.acme = {
    acceptTerms = true;
    defaults.email = config.email;
    certs."${config.domain}" = {
      dnsProvider = "cloudflare";
      environmentFile = config.sops.templates."cloudflare.env".path;
      group = "nginx";
      domain = config.domain;
      extraDomainNames = [ "*.${config.domain}" ];
      reloadServices = [ "nginx" ];
    };
  };
}
