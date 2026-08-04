# Hybrid graphics: Intel UHD 630 (Coffee Lake) + NVIDIA Quadro.
{ config, pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD) userspace
      vpl-gpu-rt # oneVPL (QSV) runtime

      # This CPU is Coffee Lake (UHD 630, Gen9.5) — the current
      # intel-compute-runtime only supports 12th Gen and newer, so it silently
      # exposes zero OpenCL platforms on this chip. Use the legacy1 build,
      # which covers Gen8/Gen9/Gen11.
      intel-compute-runtime-legacy1 # OpenCL (NEO) + Level Zero for Gen8/9/11
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;

    powerManagement.enable = false;
    powerManagement.finegrained = false;

    prime = {
      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";

      # eDP-1 is wired to the Intel iGPU, not the NVIDIA GPU, so it still
      # has to drive the panel — sync mode makes NVIDIA do all the
      # rendering by default (no nvidia-offload wrapper needed) and pass
      # frames to Intel for display, instead of offload mode's on-demand
      # per-command GPU selection.
      sync.enable = true;
    };
  };
}
