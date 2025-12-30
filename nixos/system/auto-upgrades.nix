{ inputs, ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--print-build-logs"
    ];
    dates = "04:30";
    fixedRandomDelay = true;
    randomizedDelaySec = "45min";
    allowReboot = true;
    rebootWindow = {
      lower = "04:00";
      upper = "06:00";
    };
  };
}
