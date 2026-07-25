{
  flake.modules.nixos.nvme-apst = {
    # Disable NVMe APST (autonomous power state transitions): suspected cause of
    # the SSD controller dropping off the bus mid-flight (Buffer I/O errors on
    # nvme0n1p2, box frozen with dead root fs — see docs/ares-crash-investigation.md).
    # Latency 0 = drive never enters low-power states.
    boot.kernelParams = [ "nvme_core.default_ps_max_latency_us=0" ];
  };
}
