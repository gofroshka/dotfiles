{
  flake.modules.nixos.zsh = {
    programs.zsh = {
      enable = true;
      # The user's Home Manager configuration owns compinit and plugins.
      enableCompletion = false;
    };
  };

  flake.modules.homeManager.zsh = {
    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        initContent = ''
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
          zstyle ':completion:*' menu select
          bindkey -e
        '';
      };
      direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
      starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = true;
          directory.truncation_length = 3;
        };
      };
      fzf = {
        enable = true;
        enableZshIntegration = true;
      };
    };
    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };
}
