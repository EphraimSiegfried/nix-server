{
  flake.modules.nixos.watchdog = {
    # NMI watchdog detects hard lockups
    boot.kernelParams = [ "nmi_watchdog=1" ];
    boot.kernel.sysctl = {
      "kernel.nmi_watchdog" = 1;
      "kernel.panic" = 10; # reboot 10 seconds after kernel panic
    };
    # systemd hardware watchdog: reboots if system is unresponsive for 30s
    systemd.settings.Manager = {
      RuntimeWatchdogSec = "30";
      RebootWatchdogSec = "2min";
    };
  };
}
