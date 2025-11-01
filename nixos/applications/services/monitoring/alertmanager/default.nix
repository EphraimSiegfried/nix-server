{ config, ... }:
let
  port = 9093;
  subdomain = "am";
in
{
  sops.secrets."bot/smtp-token" = { };
  services.prometheus = {
    alertmanager = {
      enable = true;
      port = port;
      webExternalUrl = "https://${subdomain}.${config.domain}";
      openFirewall = true;
      checkConfig = true;
      # Docs: https://prometheus.io/docs/alerting/latest/configuration/
      configuration = {
        global = {
          smtp_from = config.bot.mail;
          smtp_smarthost = config.bot.smtp_server;
          smtp_auth_username = config.bot.mail;
          smtp_auth_password_file = config.sops.secrets."bot/smtp-token".path;
        };
        route = {
          # The labels by which incoming alerts are grouped together. For example,
          # multiple alerts coming in for cluster=A and alertname=LatencyHigh would
          # be batched into a single group.
          group_by = [ "..." ];
          # How long to initially wait to send a notification for a group
          # of alerts. Allows to wait for an inhibiting alert to arrive or collect
          # more initial alerts for the same group.
          group_wait = "30s";
          # How long to wait before sending a notification about new alerts that
          # are added to a group of alerts for which an initial notification has
          # already been sent.
          group_interval = "5m";
          # How long to wait before sending a notification again if it has already
          # been sent successfully for an alert.
          repeat_interval = "4h";
          receiver = "default";
        };
        receivers = [
          {
            name = "default";
            email_configs = [
              {
                to = "ephraim.siegfried@proton.me";
                send_resolved = true;
              }
            ];
          }
        ];
      };
    };
    ruleFiles = [ ./alerts.yml ];
    alertmanagers = [
      {
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString port}"
            ];
          }
        ];
      }
    ];
  };

  # services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
  #   useACMEHost = config.domain;
  #   forceSSL = true;
  #   locations."/" = {
  #     proxyPass = "http://127.0.0.1:${toString port}";
  #     recommendedProxySettings = true;
  #   };
  # };
}
