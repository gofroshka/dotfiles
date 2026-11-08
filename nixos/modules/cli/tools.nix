{
  flake.modules.homeManager.cli-tools = { pkgs, ... }: {
    home.packages = with pkgs; [
      btop
      curl
      fastfetch
      fd
      ripgrep
      unzip
      jq
      file
    ];
  };

  flake.modules.homeManager.git = { pkgs, ... }: {
    # No previous declarative Git/gh/LazyGit settings to migrate; keep their
    # mutable configs and authentication under application ownership.
    home.packages = [
      pkgs.git
      pkgs.gh
      pkgs.lazygit
    ];
  };
}
