{
  flake.modules.nixos.alloy =
    { config, ... }:
    {
      services.alloy.enable = true;

      environment.etc."alloy/config.alloy".text = ''
        loki.relabel "journal" {
          forward_to = []

          rule {
            source_labels = ["__journal__systemd_unit"]
            target_label  = "unit"
          }
        }

        loki.source.journal "read" {
          max_age       = "12h"
          labels        = {
            job  = "systemd-journal",
            host = "${config.networking.hostName}",
          }
          relabel_rules = loki.relabel.journal.rules
          forward_to    = [loki.write.default.receiver]
        }

        loki.write "default" {
          endpoint {
            url = "http://10.100.0.1:3030/loki/api/v1/push"
          }
        }
      '';
    };
}
