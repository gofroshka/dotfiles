{ pkgs, lib, ... }:
{
  vim = {
    lsp = {
      enable = true;
      formatOnSave = true;
      servers = {
        # The nvf preset currently points at pkgs.typescript, not typescript_7.
        lua-language-server.settings.Lua = {
          runtime.version = "LuaJIT";
          diagnostics.globals = [
            "vim"
            "Snacks"
          ];
          workspace = {
            checkThirdParty = false;
            library = [ "${pkgs.neovim-unwrapped}/share/nvim/runtime" ];
          };
        };
      };
    };

    # nvf supplies language servers and absolute Nix store launch commands.
    # Formatters remain project-local through Conform below.
    languages = {
      nix.enable = true;
      lua.enable = true;
      typescript = {
        enable = true;
        lsp.servers = [ "typescript-go" ];
      };
      tsx.enable = true;
      astro.enable = true;
      svelte.enable = true;
      html.enable = true;
      css.enable = true;
      scss.enable = true;
      json.enable = true;
      yaml.enable = true;
      bash.enable = true;
      toml.enable = true;
      go.enable = true;
      python = {
        enable = true;
        lsp.servers = [
          "basedpyright"
          "ruff"
        ];
      };
      rust.enable = true;
      clang.enable = true;
      docker.enable = true;
      terraform.enable = true;
    };

    diagnostics = {
      enable = true;
      config = {
        severity_sort = true;
        signs = true;
        float = {
          border = "rounded";
          source = "if_many";
        };
      };
    };

    luaConfigRC.lsp-servers = lib.nvim.dag.entryAfter [ "pluginConfigs" ] "";

    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        notify_no_formatters = false;

        default_format_opts = {
          timeout_ms = 3000;
          lsp_format = "fallback";
        };
        format_after_save = null;

        formatters_by_ft =
          lib.genAttrs
            [
              "astro"
              "svelte"
              "javascript"
              "javascriptreact"
              "typescript"
              "typescriptreact"
              "css"
              "scss"
              "html"
              "json"
              "jsonc"
              "yaml"
              "markdown"
            ]
            (_: [
              "prettier"
            ])
          // {
            lua = [ "stylua" ];
            nix = [ "nixfmt" ];
            go = [
              "goimports"
              "gofumpt"
            ];
            python = [
              "ruff_organize_imports"
              "ruff_format"
            ];
            rust = [ "rustfmt" ];
            c = [ "clang_format" ];
            cpp = [ "clang_format" ];
            sh = [ "shfmt" ];
            toml = [ "taplo" ];
            terraform = [ "tofu_fmt" ];
            dockerfile = [ "dockerfmt" ];
          };
      };
    };
  };
}
