{ pkgs, ... }:
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
      autoformat = true;
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
    additionalRuntimePaths = [
      {
        path = ../config;
        position = "prepend";
      }
    ];
    luaConfigPost = ''
      require("work.lsp").setup()
      require("work.keymaps").setup()
    '';

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
    treesitter = {
      enable = true;
      grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
        astro
        bash
        css
        diff
        dockerfile
        go
        gomod
        gowork
        gosum
        hcl
        html
        javascript
        jsdoc
        json
        lua
        luadoc
        markdown
        markdown_inline
        nix
        python
        regex
        rust
        sql
        svelte
        toml
        tsx
        typescript
        yaml
      ];
      filetypeMappings.json = [ "jsonc" ];
    };
    languages.html = {
      enable = true;
      lsp.enable = false;
      format.enable = false;
      treesitter = {
        enable = true;
        autotagHtml = true;
      };
    };
  };
}
