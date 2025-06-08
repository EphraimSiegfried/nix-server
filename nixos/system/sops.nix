{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  environment = {
    systemPackages = [ pkgs.sops ];
    sessionVariables = {
      SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
      EDITOR = "nvim";
    };
  };
  systemd.tmpfiles.rules = [
    "f ${config.sops.age.keyFile} 0640 root root"
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/var/lib/age/keys.txt";
  };
}
