{
  flake.modules.nixos.github-runner =
    { config, pkgs, ... }:
    {
      # Fine-grained PAT scoped to PartnefyUNGA/partnefy with
      # "Administration: read & write" — exchanged for short-lived
      # registration tokens on every (ephemeral) re-registration.
      sops.secrets.github-runner-token = { };

      services.github-runners.partnefy = {
        enable = true;
        # One job per registration, fresh work dir every time; the nix store
        # persists via the host daemon, which is where the speed comes from.
        ephemeral = true;
        replace = true;
        url = "https://github.com/PartnefyUNGA/partnefy";
        tokenFile = config.sops.secrets.github-runner-token.path;
        extraPackages = with pkgs; [
          devenv
          git # actions/checkout
          jq # used outside the devenv shell in publish-search-worker
        ];
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
