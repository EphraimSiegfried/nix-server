{
  flake.modules.nixos.ssh = {
    networking.firewall.allowedTCPPorts = [ 22 ];
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
  };
}
