{ pkgs, ... }:

{

  programs.niri.enable = true;
  programs.dms-shell.enable = true;

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

    # Инструменты разработки
    gcc
    lazygit
    opencode
    tree-sitter

    # Rust: компилятор, сборка, LSP, форматирование и проверки
    cargo
    clippy
    rust-analyzer
    rustc
    rustfmt

    # Nix: LSP, форматирование и проверки
    deadnix
    nil
    nixfmt
    statix

    # Lua: конфигурация Neovim
    lua-language-server
    stylua

    # Python: интерпретатор, LSP и проверки
    pyright
    python3
    ruff

    # Web: JavaScript, TypeScript, Svelte и Tailwind
    nodejs
    prettier
    svelte-language-server
    tailwindcss-language-server
    typescript
    vtsls

    # SQL: LSP, форматирование и проверки
    sqlfluff
    sqls

    # Документация и конфигурационные файлы
    markdown-toc
    markdownlint-cli2
    shfmt
    taplo
    yaml-language-server

    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    zellij
    bibata-cursors
    git
    libsForQt5.qt5ct
    kdePackages.qt6ct
  ];
}
