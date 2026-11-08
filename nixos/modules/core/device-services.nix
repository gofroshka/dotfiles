{
  flake.modules.nixos.device-services = {
    services = {
      power-profiles-daemon.enable = true;
      upower.enable = true;
      udisks2.enable = true;
      gvfs.enable = true;
    };
    programs.gpu-screen-recorder.enable = true;
  };
}
