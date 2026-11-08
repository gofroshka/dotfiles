-- External tools are installed with Nix, not Mason.
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- The built-in Svelte extra resolves its TS plugin through Mason.
      -- Configure the language server directly instead.
      opts.servers.svelte = { mason = false }
      opts.servers.sqls = { mason = false }
      for _, server in pairs(opts.servers) do
        if type(server) == "table" then
          server.mason = false
        end
      end
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "svelte" } },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters = opts.formatters or {}
      opts.formatters.bun_fmt = {
        command = "bun",
        args = { "fmt", "--no-script", "--stdin-filepath", "$FILENAME" },
        stdin = true,
        cwd = require("conform.util").root_file({ "bunfig.toml", "package.json", ".git" }),
      }

      -- Replace Prettier from language extras, preserving other formatters.
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, formatters in pairs(opts.formatters_by_ft) do
        if type(formatters) == "table" then
          for i, name in ipairs(formatters) do
            if name == "prettier" or name == "prettierd" then
              formatters[i] = "bun_fmt"
            end
          end
        end
      end

      for _, ft in ipairs({
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "css",
        "scss",
        "less",
        "html",
        "svelte",
        "yaml",
      }) do
        opts.formatters_by_ft[ft] = { "bun_fmt" }
      end
    end,
  },
}
