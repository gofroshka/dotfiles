-- Project tool resolution; all executable installation belongs to Nix/devenv.
local M = {}

function M.root(buf)
  local file = vim.api.nvim_buf_get_name(buf or 0)
  return vim.fs.root(file ~= "" and file or vim.uv.cwd(), {
    "devenv.nix",
    ".git",
    "flake.nix",
    "package.json",
    "Cargo.toml",
    "go.mod",
    "pyproject.toml",
  }) or vim.uv.cwd()
end

function M.find(command, buf)
  local file = vim.api.nvim_buf_get_name(buf or 0)
  local dir = file ~= "" and vim.fs.dirname(file) or vim.uv.cwd()
  for parent in vim.fs.parents(dir .. "/_") do
    local candidate = parent .. "/node_modules/.bin/" .. command
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  local path = vim.fn.exepath(command)
  return path ~= "" and path or nil
end

function M.native_typescript()
  local seen = {}
  for _, command in ipairs({ "tsgo", "tsc" }) do
    local candidates = { M.find(command) }
    for dir in (vim.env.PATH or ""):gmatch("[^:]+") do
      candidates[#candidates + 1] = dir .. "/" .. command
    end
    for _, path in ipairs(candidates) do
      if not seen[path] and vim.fn.executable(path) == 1 then
        seen[path] = true
        local result = vim.system({ path, "--version" }, { text = true }):wait(3000)
        local major = tonumber((result.stdout or ""):match("(%d+)%.%d+"))
        if result.code == 0 and major and major >= 7 then
          return path
        end
      end
    end
  end
end

function M.formatters(ft, buf)
  local function available(names)
    return vim.tbl_filter(function(name)
      return M.find(
        ({ ruff_format = "ruff", ruff_organize_imports = "ruff", terraform_fmt = "terraform" })[name] or name,
        buf
      ) ~= nil
    end, names)
  end
  if ft == "go" then
    return available({ "goimports", M.find("gofumpt", buf) and "gofumpt" or "gofmt" })
  elseif ft == "python" then
    return available(M.find("ruff", buf) and { "ruff_organize_imports", "ruff_format" } or { "black" })
  end
  local simple =
    { lua = "stylua", nix = "nixfmt", rust = "rustfmt", sh = "shfmt", toml = "taplo", terraform = "terraform_fmt" }
  if simple[ft] then
    return available({ simple[ft] })
  end
  local file = vim.api.nvim_buf_get_name(buf or 0)
  local biome = vim.fs.find({ "biome.json", "biome.jsonc" }, { path = vim.fs.dirname(file), upward = true })[1]
  if ft ~= "astro" and ft ~= "svelte" and biome and M.find("biome", buf) then
    return { "biome" }
  end
  return available({ "prettier" })
end

return M
