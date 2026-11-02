{
  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;

    udisks2.enable = true;
    gvfs.enable = true;

    displayManager.dux-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/gofroshka";
    };
  };
}
