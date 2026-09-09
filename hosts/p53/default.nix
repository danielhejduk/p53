{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix

    ../../modules/system/boot.nix
    ../../modules/system/locale.nix
    ../../modules/system/networking.nix
    ../../modules/system/nix.nix
    ../../modules/desktop/gnome.nix
    ../../modules/desktop/audio.nix
    ../../modules/hardware/peripherals.nix
    ../../modules/programs
  ];

  networking.hostName = "p53";

  # Diagnostic tooling for the intermittent AC-adapter blip under GPU load:
  # acpi_listen shows live ACPI/EC events (e.g. distinguishing a real AC
  # off-line event from an unhandled thinkpad_acpi HKEY event), and sensors
  # exposes voltage/power rails if the board reports them.
  environment.systemPackages = with pkgs; [
    acpica-tools
    lm_sensors
  ];

  # Verbose thinkpad_acpi logging to capture more context around unhandled
  # HKEY events (e.g. 0x6031) if the AC blip recurs.
  boot.extraModprobeConfig = "options thinkpad_acpi debug=0xffff";

  users.users.danik = {
    isNormalUser = true;
    description = "Daniel Hejduk";
    extraGroups = [ "networkmanager" "wheel" "plugdev" ];
  };

  home-manager = {
    # Reuse the system nixpkgs instead of instantiating a second one, so
    # nixpkgs.config (allowUnfree, insecure packages) applies to both.
    useGlobalPkgs = true;

    # Back up (rather than clobber) any pre-existing files that home-manager
    # wants to manage, e.g. the ~/.config/gh/config.yml that `gh` created itself.
    backupFileExtension = "backup";

    users.danik = import ../../home/danik.nix;
  };

  # Release of the first install of this system. Do not change.
  system.stateVersion = "26.05";
}
