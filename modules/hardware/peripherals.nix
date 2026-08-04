# Embedded-development hardware access: Raspberry Pi Compute Modules, SEGGER
# J-Link, plus the laptop's fingerprint reader and Thunderbolt dock.
{ lib, pkgs, ... }:

{
  # `plugdev` isn't a group NixOS creates by default; declare it so it can be
  # referenced in users.users.<name>.extraGroups (otherwise the group is
  # silently dropped).
  users.groups.plugdev = { };

  # Direct USB access to Raspberry Pi Compute Modules in USB-boot mode, so
  # `rpiboot` can talk to them without root. Being in `plugdev` alone does
  # nothing without a matching udev rule — this is that rule.
  #   0a5c:2763  BCM2835 (CM1)
  #   0a5c:2764  BCM2710 (CM3)
  #   0a5c:2711  BCM2711 (CM4)
  #   0a5c:2712  BCM2712 (CM5)
  # GROUP="plugdev" covers group members; TAG+="uaccess" additionally grants
  # the active desktop-session user access via logind ACLs, which works even
  # before a fresh login picks up plugdev membership.
  services.udev.extraRules = lib.concatMapStrings (product: ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0a5c", ATTRS{idProduct}=="${product}", MODE="0660", GROUP="plugdev", TAG+="uaccess"
  '') [ "2763" "2764" "2711" "2712" ];

  # Install the SEGGER J-Link udev rules (99-jlink.rules) so the debug probe
  # is accessible without root. segger-jlink is flagged insecure, so it must
  # also be whitelisted here at the system level.
  services.udev.packages = [ pkgs.segger-jlink ];
  nixpkgs.config.permittedInsecurePackages = [ "segger-jlink-qt4-874" ];
  nixpkgs.config.segger-jlink.acceptLicense = true;

  services.fprintd.enable = true;
  services.hardware.bolt.enable = true;
}
