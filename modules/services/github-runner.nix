{ inputs, ... }:
{
  flake.modules.nixos.github-runner =
    { config, pkgs, ... }:
    let
      # devenv moves faster than nixos stable — take it from unstable so the
      # CLI driving CI stays close to what developers run locally.
      devenv = inputs.nixpkgs_unstable.legacyPackages.${pkgs.system}.devenv;
      runner = url: tokenSecret: {
        enable = true;
        # One job per registration, fresh work dir every time; the nix store
        # persists via the host daemon, which is where the speed comes from.
        ephemeral = true;
        replace = true;
        inherit url;
        tokenFile = config.sops.secrets.${tokenSecret}.path;
        extraPackages = [
          devenv
          pkgs.git # actions/checkout
          pkgs.jq # used outside the devenv shell in publish-search-worker
        ];
      };
    in
    {
      # Fine-grained PATs with "Administration: read & write" on the target
      # repo — exchanged for short-lived registration tokens on every
      # (ephemeral) re-registration.
      sops.secrets = {
        github-runner-token = { };
        github-runner-token-zenix = { };
      };

      services.github-runners = {
        partnefy = runner "https://github.com/PartnefyUNGA/partnefy" "github-runner-token";
        zenix = runner "https://github.com/zenoli/zenix" "github-runner-token-zenix";
      };

      nix = {
        # CI builds only get CPU/IO when no other service wants it.
        daemonCPUSchedPolicy = "idle";
        daemonIOSchedClass = "idle";
        # Jobs run as an untrusted dynamic user, so substituters must be
        # configured system-wide. Listing any substituter drops the default,
        # hence cache.nixos.org is repeated here.
        settings = {
          substituters = [
            "https://cache.nixos.org"
            "https://devenv.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
        };
      };
    };
}
