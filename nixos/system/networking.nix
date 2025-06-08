{
  networking = {
    hostName = "ares";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 81 443 ];
    };
  };
}
