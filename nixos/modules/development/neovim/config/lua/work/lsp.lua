local tools = require("work.tools")
local M = { servers = {} }

function M.setup()
  vim.diagnostic.config({ severity_sort = true, float = { border = "rounded", source = "if_many" } })
  vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
  local native = tools.native_typescript()
  local servers = {
    lua_ls = "lua-language-server",
    nil_ls = "nil",
    gopls = "gopls",
    rust_analyzer = "rust-analyzer",
    basedpyright = "basedpyright-langserver",
    ruff = "ruff",
    bashls = "bash-language-server",
    astro = "astro-ls",
    svelte = "svelteserver",
    jsonls = "vscode-json-language-server",
    yamlls = "yaml-language-server",
    html = "vscode-html-language-server",
    cssls = "vscode-css-language-server",
    taplo = "taplo",
    terraformls = "terraform-ls",
    dockerls = "docker-langserver",
    clangd = "clangd",
  }
  if not tools.find("basedpyright-langserver") then
    servers.pyright = "pyright-langserver"
  end
  servers[native and "tsc" or "ts_ls"] = native or "typescript-language-server"
  M.servers = {}
  for name, command in pairs(servers) do
    local path = tools.find(command)
    if path then
      local config = {}
      if name == "tsc" then
        config.cmd = { path, "--lsp", "--stdio" }
        config.root_dir = function(buf, on_dir)
          if not vim.fs.root(buf, { "deno.json", "deno.jsonc" }) then
            on_dir(tools.root(buf))
          end
        end
      elseif name == "gopls" then
        config.settings = { gopls = { gofumpt = true, staticcheck = true } }
      elseif name == "lua_ls" then
        config.settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim", "Snacks" } },
            workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
          },
        }
      end
      vim.lsp.config(name, config)
      vim.lsp.enable(name)
      M.servers[name] = path
    else
      M.servers[name] = "not installed — use devenv"
    end
  end
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("work_lsp", { clear = true }),
    callback = function(event)
      vim.keymap.set("n", "<leader>cl", "<cmd>checkhealth vim.lsp<cr>", { buffer = event.buf, desc = "LSP Info" })
      vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { buffer = event.buf, desc = "Signature Help" })
      vim.keymap.set({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = event.buf, desc = "Code Action" })
    end,
  })
end

return M
