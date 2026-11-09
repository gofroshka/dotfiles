{
  flake.modules.nixos.niri = {
    programs.niri.enable = true;
  };

  flake.modules.homeManager.niri = { lib, ... }: {
    xdg.configFile = {
      "niri/config.kdl".source = ./config/config.kdl;
      "niri/binds.kdl".source = ./config/binds.kdl;
      "niri/window-rules.kdl".source = ./config/window-rules.kdl;
      "niri/host.kdl".text = lib.mkDefault "";
    };
  };
}
