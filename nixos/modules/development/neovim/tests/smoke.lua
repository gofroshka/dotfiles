local function check()
  local function no_errors()
    local messages = vim.api.nvim_exec2("messages", { output = true }).output
    for _, pattern in ipairs({ "Error detected", "Failed to run", "E5113:" }) do
      assert(not messages:find(pattern, 1, true), messages)
    end
    for _, notification in ipairs(Snacks.notifier.get_history({ filter = "error" })) do
      error(notification.msg)
    end
  end
  assert(vim.env.NVIM_APPNAME == "nvf")
  assert(not _G.LazyVim and not package.loaded.lazy and not package.loaded["lz.n"])
  assert(vim.fn.exists(":Lazy") == 0 and vim.fn.exists(":Mason") == 0)
  assert(vim.g.colors_name == "zed-macos-classic-dark")
  for _, module in ipairs({ "snacks", "blink.cmp", "conform", "which-key", "lualine", "bufferline", "gitsigns" }) do
    assert(package.loaded[module], module .. " was not configured")
  end
  assert(vim.fn.maparg("<leader>e", "n") ~= "")
  assert(vim.fn.maparg("<leader>cf", "n") ~= "")
  no_errors()
  local picker = Snacks.picker.files({ cwd = vim.uv.cwd() })
  assert(
    vim.wait(10000, function()
      return picker:count() > 0
    end, 50),
    "File picker returned no files"
  )
  picker:close()
  local explorer = Snacks.explorer({ cwd = vim.uv.cwd() })
  assert(
    vim.wait(10000, function()
      return explorer:count() > 0
    end, 50),
    "Explorer returned no files"
  )
  explorer:close()

  local tools = require("work.tools")
  local servers = require("work.lsp").servers
  local checks = {}
  for _, item in ipairs({
    { "astro", "astro" },
    { "svelte", "svelte" },
    { "ts", servers.tsc and "tsc" or "ts_ls" },
  }) do
    local file = vim.fn.globpath(vim.uv.cwd(), "src/**/*." .. item[1], false, true)[1]
    local server = servers[item[2]]
    if file and server and server:sub(1, 1) == "/" then
      checks[#checks + 1] = { file, item[2] }
    end
  end
  if #checks == 0 then
    local file = vim.fn.tempname() .. ".lua"
    vim.fn.writefile({ "local answer = 42", "return answer" }, file)
    checks = { { file, tools.find("lua-language-server") and "lua_ls" or nil } }
  end
  for _, item in ipairs(checks) do
    vim.cmd.edit(vim.fn.fnameescape(item[1]))
    local buf = vim.api.nvim_get_current_buf()
    if item[2] then
      assert(
        vim.wait(30000, function()
          return #vim.lsp.get_clients({ bufnr = buf, name = item[2] }) > 0
        end, 100),
        item[2] .. " did not attach"
      )
    end
    assert(pcall(vim.treesitter.get_parser, buf), "Missing Nix-built parser: " .. vim.bo[buf].filetype)
    local conform = require("conform")
    if #conform.list_formatters(buf) > 0 then
      local format_err
      conform.format({ bufnr = buf, dry_run = true, lsp_format = "never", timeout_ms = 15000 }, function(err)
        format_err = err
      end)
      assert(not format_err, format_err)
    end
    io.stdout:write("PASS: " .. (item[2] or "editor") .. " / formatting / " .. vim.bo[buf].filetype .. "\n")
  end
  no_errors()
  io.stdout:write("PASS: nvf, Nix-built plugins/parsers, theme, controls, picker/explorer; no runtime plugin manager\n")
end

vim.schedule(function()
  local ok, err = xpcall(check, debug.traceback)
  for _, client in ipairs(vim.lsp.get_clients()) do
    client:stop(true)
  end
  if ok then
    vim.cmd("qa!")
  else
    io.stderr:write(err .. "\n")
    vim.cmd("cquit 1")
  end
end)
