{
  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;

    displayManager.dms-greeter = {
      enable = true;
      compositor.name = "niri";
      configHome = "/home/gofroshka";
    };
  };
}
