{
  flake.modules.nixos.jellyfin =
    { config, pkgs, ... }:
    let
      subdomain = "jelly";
      port = 8096;
    in
    {
      webServices.jellyfin = {
        name = "Jellyfin";
        subdomain = subdomain;
        inherit port;
        description = "Media server for streaming movies, shows, and music";
        category = "Media";
      };

      nixarr.jellyfin = {
        enable = true;
        openFirewall = true;
      };
      networking.firewall.allowedTCPPorts = [ port ];

      nixpkgs.config.packageOverrides = pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      };
      hardware = {
        graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            intel-vaapi-driver
            libva-vdpau-driver
            libvdpau-va-gl
            intel-compute-runtime
            vpl-gpu-rt
          ];
        };
        intel-gpu-tools.enable = true;
      };
      environment.systemPackages = with pkgs; [
        intel-gpu-tools
      ];
    };
}
