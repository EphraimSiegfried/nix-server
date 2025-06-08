{
  networking = {
    firewall = {
      allowedTCPPorts = [ 53 ];
      allowedUDPPorts = [ 53 ];
    };
  };
  services.adguardhome = {
    enable = true;
    port = 3000;
    openFirewall = true;
    settings = {
      dns = {
        upstream_dns = [
          "9.9.9.9"
          "149.112.112.112"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
      };
      filters = map (url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
      ];
    };
  };
}
