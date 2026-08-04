{
  networking.networkmanager.enable = true;

  services.openssh.enable = true;

  # Proxy client; tunMode routes traffic through a TUN interface.
  programs.throne = {
    enable = true;
    tunMode.enable = true;
  };
}
