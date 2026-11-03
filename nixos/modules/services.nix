{
  services = {
    power-profiles-daemon.enable = true;
    upower.enable = true;

    udisks2.enable = true;
    gvfs.enable = true;

    displayManager = {

      autoLogin = {
        enable = true;
        user = "gofroshka";
      };

      defaultSession = "niri";

      dux-greeter = {
        enable = true;
        compositor.name = "niri";
        configHome = "/home/gofroshka";
      };
    };
  };
}
