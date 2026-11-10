{ pkgs, ... }:
{
  vim = {
    lsp = {
      enable = true;
      formatOnSave = true;
    };

    languages = {
      enableTreesitter = true;
      enableFormat = true;

      nix.enable = true;
      lua.enable = true;
      typescript.enable = true;
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

    treesitter = {
      # Language modules supply their own parsers; these cover extra syntax.
      grammars = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
        diff
        hcl
        jsdoc
        luadoc
        markdown
        markdown_inline
        regex
        sql
      ];
      filetypeMappings.json = [ "jsonc" ];
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
  };
}
