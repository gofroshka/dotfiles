{ pkgs, lib, ... }:
let
  raw = lib.generators.mkLuaInline;
in
{
  vim = {
    startPlugins = [ pkgs.vimPlugins.nvim-lspconfig ];
    # Runtime detection keeps language servers/toolchains in devenv, not in nvf.
    lsp = {
      enable = true;
      mappings = {
        goToDefinition = "gd";
        goToDeclaration = "gD";
        goToType = "gy";
        listImplementations = "gI";
        listReferences = "gr";
        nextDiagnostic = "]d";
        previousDiagnostic = "[d";
        openDiagnosticFloat = "<leader>cd";
        hover = "K";
        signatureHelp = "gK";
        renameSymbol = "<leader>cr";
        codeAction = "<leader>ca";
        listDocumentSymbols = "<leader>ss";
        listWorkspaceSymbols = "<leader>sS";
        format = "<leader>cf";
        toggleFormatOnSave = null;
      };
    };
    formatter.conform-nvim = {
      enable = true;
      setupOpts = {
        notify_no_formatters = false;
        default_format_opts = {
          timeout_ms = 3000;
          lsp_format = "fallback";
        };
        format_after_save = null;
        format_on_save = raw ''
          function(buf)
            if vim.g.autoformat ~= false and vim.b[buf].autoformat ~= false then
              return { timeout_ms = 3000, lsp_format = "fallback" }
            end
          end
        '';
        formatters_by_ft = lib.genAttrs [
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
          "lua"
          "nix"
          "go"
          "rust"
          "python"
          "sh"
          "toml"
          "terraform"
        ] (ft: raw ''function(buf) return require("work.tools").formatters("${ft}", buf) end'');
      };
    };
  };
}
