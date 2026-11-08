{
  flake.modules.homeManager.zellij = { pkgs, ... }: {
    home.packages = [ pkgs.zellij ];
    xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  };
}
