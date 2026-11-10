{ pkgs, lib, ... }:
{
  vim = {
    # Nix owns plugins and parsers; nothing is installed on editor startup.
    lazy.enable = false;
    viAlias = true;
    vimAlias = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
    globals = {
      mapleader = " ";
      maplocalleader = "\\";
    };
    options = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      ignorecase = true;
      smartcase = true;
      splitbelow = true;
      splitright = true;
      termguicolors = true;
      undofile = true;
      signcolumn = "yes";
      cursorline = true;
      scrolloff = 4;
      laststatus = 3;
      showmode = false;
      wrap = false;
      mouse = "a";
      clipboard = "unnamedplus";
      updatetime = 200;
      timeoutlen = 300;
      completeopt = "menu,menuone,noselect";
      foldlevel = 99;
    };
    extraPackages = with pkgs; [
      git
      ripgrep
      fd
      lazygit
      trash-cli
      wl-clipboard
    ];
    augroups = [ { name = "work_editor"; } ];
    autocmds = [
      {
        event = [ "TextYankPost" ];
        group = "work_editor";
        desc = "Highlight copied text";
        callback = lib.generators.mkLuaInline "vim.hl.on_yank";
      }
    ];

    autopairs.nvim-autopairs.enable = true;
    autocomplete.blink-cmp = {
      enable = true;
      friendly-snippets.enable = true;
      setupOpts = {
        fuzzy.implementation = "lua";
        keymap.preset = "enter";
        completion.documentation.auto_show = true;
      };
    };
    # Use nixpkgs' cached build rather than rebuilding nvf's Rust matcher.
    pluginOverrides.blink-cmp = pkgs.vimPlugins.blink-cmp;
  };
}
