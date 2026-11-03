{ pkgs, ... }:

{

  programs = {
    niri.enable = true;
    dux-shell = {
      enable = true;

      # Home Assistant plugin imports the QtWebSockets QML module.
      quickshell.package = pkgs.quickshell.overrideAttrs (old: {
        buildInputs = (old.buildInputs or []) ++ [
          pkgs.qt6.qtwebsockets
        ];
      });
    };
    dux-files = {
      enable = true;
      systemd.enable = true;
    };
    gpu-screen-recorder.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Скриншоты
    wf-recorder
    ffmpeg
    imagemagick
    img2pdf
    tesseract
    zbar
    file

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

    # Markdown
    markdownlint-cli2

    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    zellij
    bibata-cursors
    git
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];
}
