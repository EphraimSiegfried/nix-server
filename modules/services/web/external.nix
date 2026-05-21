{
  flake.modules.nixos.external = {
    webServices.grafana = {
      name = "Grafana";
      external = true;
      description = "Dashboard tool for visualizing metrics and logs";
      category = "Monitoring";
    };
    webServices.gatus = {
      name = "Gatus";
      subdomain = "health";
      external = true;
      description = "Health monitoring and alerting";
      category = "Monitoring";
    };
  };
}
