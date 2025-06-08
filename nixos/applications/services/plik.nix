{ config, ... }:
{
  # services.nginx.virtualHosts."share.${config.domain}" = {
  #   enableACME = true;
  #   forceSSL = true;
  #   locations."/" = {
  #     proxyPass = "http://127.0.0.1:3010";
  #     recommendedProxySettings = true;
  #   };
  # };

  config.virtualisation.oci-containers.containers.plik = {
    image = "rootgg/plik:latest";
    ports = [ "127.0.0.1:3010:3010" ];
    volumes = [
      "${config.data_dir}/plik:/data"
    ];
    environment = {
      "PLIKD_DATA_BACKEND_CONFIG" = "'{\"Directory\":\"/data\"}'";
    };
  };
}
