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
    programs.git = {
      enable = true;
      settings.user = {
        name = "Gofroshka";
        email = "georgiy.guse@gmail.com";
      };
    };
    # Authentication and repository-specific settings remain application-owned.
    home.packages = [
      pkgs.gh
      pkgs.lazygit
    ];
  };
}
