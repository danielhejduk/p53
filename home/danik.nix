{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings.user.email = "danielhejduk@disroot.org";
    settings.user.name = "Daniel Hejduk";
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.claude-code.enable = true;

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override { cudaSupport = true; };
  };

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    discord
    gnome-secrets
    librewolf
    nocturne
    prismlauncher
    proton-vpn-cli
    nerd-fonts.jetbrains-mono
    apostrophe
    gnome-tweaks
    monero-gui
    blender
    glab
    opencode
  ];

  imports = [
    ./vim.nix
    ./gnome.nix
    ./opencode.nix
  ];

  home.stateVersion = "26.05";
}
