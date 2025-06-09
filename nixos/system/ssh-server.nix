{
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PubkeyAuthentication = "yes";
      PermitRootLogin = "no";
      X11Forwarding = false;
      AllowTCPForwarding = "no";
      PermitTunnel = "no";
    };
  };
}
