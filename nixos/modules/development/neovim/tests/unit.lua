local source = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p")
local root = vim.fs.dirname(vim.fs.dirname(source)) .. "/config"
vim.opt.rtp:prepend(root)

local tmp = vim.fn.tempname()
local project = tmp .. "/project"
local bin = tmp .. "/bin"
local native = tmp .. "/native"
local original_path = vim.env.PATH
local original_cwd = vim.uv.cwd()

local function executable(path, version)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile({ "#!/bin/sh", "printf 'Version " .. (version or "1.0.0") .. "\\n'" }, path)
  assert(vim.uv.fs_chmod(path, 493))
end

local function check()
  vim.fn.mkdir(project .. "/src", "p")
  vim.fn.writefile({}, project .. "/devenv.nix")
  executable(project .. "/node_modules/.bin/tsc", "5.9.3")
  executable(native .. "/tsc", "7.0.2")
  executable(bin .. "/gopls")
  executable(bin .. "/typescript-language-server")
  vim.env.PATH = project .. "/node_modules/.bin:" .. bin .. ":" .. native
  vim.fn.chdir(project)
  vim.api.nvim_buf_set_name(0, project .. "/src/main.ts")

  local tools = require("work.tools")
  local lsp = require("work.lsp")
  assert(tools.root() == project)
  assert(tools.find("tsc") == project .. "/node_modules/.bin/tsc")
  assert(tools.find("missing-server") == nil)
  assert(tools.native_typescript() == native .. "/tsc", "TS 5 must not shadow native TS 7")

  local configurations = {}
  local enabled = {}
  local original_config, original_enable = vim.lsp.config, vim.lsp.enable
  vim.lsp.config = setmetatable(configurations, {
    __call = function(_, name, opts)
      configurations[name] = opts
    end,
  })
  vim.lsp.enable = function(name, value)
    enabled[name] = value ~= false
  end
  package.loaded["blink.cmp"] = {
    get_lsp_capabilities = function()
      return { textDocument = {} }
    end,
  }
  lsp.setup()
  assert(enabled.gopls and enabled.tsc and not enabled.ts_ls and not enabled.svelte)
  assert(configurations.tsc.cmd[1] == native .. "/tsc")

  vim.fn.delete(native .. "/tsc")
  enabled = {}
  lsp.setup()
  assert(not enabled.tsc and enabled.ts_ls, "Classic TypeScript LSP should be a fallback")
  vim.lsp.config, vim.lsp.enable = original_config, original_enable

  executable(bin .. "/goimports")
  executable(bin .. "/gofmt")
  assert(vim.deep_equal(tools.formatters("go", 0), { "goimports", "gofmt" }))
  executable(bin .. "/gofumpt")
  assert(vim.deep_equal(tools.formatters("go", 0), { "goimports", "gofumpt" }))
  assert(vim.deep_equal(tools.formatters("typescript", 0), {}), "Missing tools must not be scheduled")
  executable(project .. "/node_modules/.bin/prettier")
  assert(vim.deep_equal(tools.formatters("svelte", 0), { "prettier" }))
  executable(bin .. "/biome")
  vim.fn.writefile({ "{}" }, project .. "/biome.json")
  assert(vim.deep_equal(tools.formatters("typescript", 0), { "biome" }))
  assert(vim.deep_equal(tools.formatters("astro", 0), { "prettier" }), "Astro should use its Prettier plugin")
  print("PASS: project tools, native TS shadowing, LSP fallback, formatter selection")
end

local ok, err = xpcall(check, debug.traceback)
vim.env.PATH = original_path
vim.fn.chdir(original_cwd)
vim.fn.delete(tmp, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
