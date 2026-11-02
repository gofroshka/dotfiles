{ pkgs, ... }:

{
  users.users.gofroshka.shell = pkgs.zsh;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;

      interactiveShellInit = ''
        # Дополнение без учёта регистра
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

        # Выбор вариантов дополнения стрелками
        zstyle ':completion:*' menu select

        # Обычные сочетания редактирования командной строки
        bindkey -e
      '';
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        directory.truncation_length = 3;
      };
    };

    fzf = {
      keybindings = true;
      fuzzyCompletion = true;
    };
  };
}
