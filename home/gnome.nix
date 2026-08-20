{
  programs.gnome-terminal = {
    enable = true;
    package = null; # GNOME already installs it system-wide
    profile."b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      default = true;
      visibleName = "Default";
      font = "JetBrainsMono Nerd Font Mono 12"; # from nerd-fonts.jetbrains-mono in danik.nix
    };
  };

  dconf.settings = {
    # Matched to the wallpaper: dark stone ruins with golden grass and a warm
    # sunset sky.
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      accent-color = "orange";
      # GNOME Tweaks > Keyboard & Mouse > Middle Click Paste
      gtk-enable-primary-paste = true;
    };

    # GNOME Tweaks > Window Titlebars > Minimize/Maximize; the default layout
    # is "appmenu:close".
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    # Both light and dark keys are set; GNOME picks by theme, so setting only
    # one leaves the default background in the other mode.
    "org/gnome/desktop/background" = {
      picture-uri = "file://${./wallpaper.jpg}";
      picture-uri-dark = "file://${./wallpaper.jpg}";
      picture-options = "zoom";
    };

    "org/gnome/desktop/screensaver" = {
      picture-uri = "file://${./wallpaper.jpg}";
      picture-options = "zoom";
    };
  };
}
