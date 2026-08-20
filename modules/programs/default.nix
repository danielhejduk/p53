{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Shell / system
    vim
    git
    btop
    fastfetch
    pciutils
    msr-tools # needs boot.kernelModules = [ "msr" ], see modules/system/boot.nix

    # Toolchains
    gcc
    cmake
    ninja
    python3
    nodejs
    bun
    go
  ];

  # Globally installed bun packages. Set at system level because home-manager
  # does not manage the shell here, so home.sessionPath would never be sourced.
  environment.variables.PATH = [ "$HOME/.bun/bin" ];

  # Run unpatched dynamically linked binaries (vendor SDKs, prebuilt tools).
  programs.nix-ld.enable = true;

  virtualisation.podman.enable = true;
}
