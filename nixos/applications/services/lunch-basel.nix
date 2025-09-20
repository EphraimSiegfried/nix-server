{ config, pkgs, ... }:

let
  repoUrl = "https://github.com/EphraimSiegfried/lunch-basel";
  repoName = "lunch-basel";
  installDir = "/var/lib/${repoName}";
  subdomain = "zmittag";
  port = 3000;

  # Service configuration
  serviceUser = "lunch-basel";
  serviceGroup = "lunch-basel";

  # Script to clone/update and run the repository
  startupScript = pkgs.writeShellScriptBin "start-lunch-basel" ''
    set -euo pipefail

    # Create installation directory if it doesn't exist
    if [ ! -d "${installDir}" ]; then
      mkdir -p "${installDir}"
      chown ${serviceUser}:${serviceGroup} "${installDir}"
    fi

    # Clone or update the repository
    if [ ! -d "${installDir}/.git" ]; then
      echo "Cloning repository..."
      ${pkgs.git}/bin/git clone ${repoUrl} "${installDir}"
    else
      echo "Updating repository..."
      cd "${installDir}"
      ${pkgs.git}/bin/git pull
    fi

    # Set proper ownership
    chown -R ${serviceUser}:${serviceGroup} "${installDir}"
    echo "Cleaning up potential network conflicts..."
    ${pkgs.docker}/bin/docker network ls --filter name=${repoName}_default -q | while read network_id; do
      echo "Removing conflicting network: $network_id"
      ${pkgs.docker}/bin/docker network rm "$network_id" 2>/dev/null || true
    done

    # Run docker compose
    echo "Starting Docker Compose..."
    cd "${installDir}"
    ${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans --build
  '';

  # Script to stop the service
  stopScript = pkgs.writeShellScriptBin "stop-lunch-basel" ''
    set -euo pipefail

    if [ -d "${installDir}" ]; then
      echo "Stopping Docker Compose..."
      cd "${installDir}"
      ${pkgs.docker-compose}/bin/docker-compose down
    fi
  '';

in
{
  # Create user and group for the service
  users.users.${serviceUser} = {
    isSystemUser = true;
    group = serviceGroup;
    description = "Service user for lunch-basel";
    home = installDir;
    createHome = true;
    extraGroups = [ "docker" ];
  };

  users.groups.${serviceGroup} = { };

  # Systemd service definition
  systemd.services.lunch-basel = {
    description = "Lunch Basel Docker Compose Service";
    after = [
      "network.target"
      "docker.service"
    ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = serviceUser;
      Group = serviceGroup;
      WorkingDirectory = installDir;
      ExecStart = "${startupScript}/bin/start-lunch-basel";
      ExecStop = "${stopScript}/bin/stop-lunch-basel";
      RemainAfterExit = true;
      TimeoutStartSec = "300";
      TimeoutStopSec = "120";
    };

    path = with pkgs; [
      git
      docker
      docker-compose
    ];

    environment = {
      # Set HOME for the service user
      HOME = installDir;
    };
  };

  # Ensure Docker is available
  virtualisation.docker.enable = true;

  # Optional: Create a timer for automatic updates
  # systemd.timers.lunch-basel-update = lib.mkIf false {
  #   # Disabled by default
  #   description = "Timer for updating lunch-basel repository";
  #   timerConfig = {
  #     OnCalendar = "daily";
  #     Persistent = true;
  #   };
  #   wantedBy = [ "timers.target" ];
  # };
  #
  # systemd.services.lunch-basel-update = lib.mkIf false {
  #   description = "Update lunch-basel repository";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = serviceUser;
  #     Group = serviceGroup;
  #     ExecStart = "${pkgs.git}/bin/git -C ${installDir} pull";
  #   };
  # };

  services.nginx.virtualHosts."${subdomain}.${config.domain}" = {
    useACMEHost = config.domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      recommendedProxySettings = true;
    };
  };

}
