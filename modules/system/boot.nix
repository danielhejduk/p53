{ pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # MSR access for msr-tools (see modules/programs).
  boot.kernelModules = [ "msr" ];
}
