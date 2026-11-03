{ pkgs, ... }:

{

  programs = {
    niri.enable = true;
    dux-shell.enable = true;
    dux-files = {
      enable = true;
      systemd.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Приложения
    firefox
    ghostty
    telegram-desktop

    # Системные и консольные утилиты
    btop
    curl
    fastfetch
    fd
    fzf
    ripgrep
    unzip

    # Общие инструменты редактора и разработки
    gcc
    lazygit
    opencode
    tree-sitter

    # Nix: LSP, форматирование и проверки
    deadnix
    nil
    nixfmt
    statix

    # Lua: конфигурация Neovim
    lua-language-server
    stylua

    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    zellij
    bibata-cursors
    git
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];
}
