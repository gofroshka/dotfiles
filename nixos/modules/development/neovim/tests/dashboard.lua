-- An actual TUI in a pty: dashboard autostart intentionally skips headless UIs.
local binary = assert(vim.env.NVIM_TEST_BINARY, "Set NVIM_TEST_BINARY to the built nvf executable")
local tmp = vim.fn.tempname()
local project = tmp .. "/demo"
local file = project .. "/example.lua"
local jobs, channels, watchdogs = {}, {}, {}

local function start(args)
  local socket = tmp .. "/ui-" .. (#jobs + 1) .. ".sock"
  local command = { binary, "--listen", socket }
  vim.list_extend(command, args or {})
  vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(false, true))
  local job = vim.fn.jobstart(command, { term = true, cwd = project, width = 140, height = 44 })
  assert(job > 0, "Could not start the test TUI")
  jobs[#jobs + 1] = job
  local terminal = vim.api.nvim_get_current_buf()
  watchdogs[#watchdogs + 1] = vim.defer_fn(function()
    if vim.fn.jobwait({ job }, 0)[1] == -1 then
      local output = table.concat(vim.api.nvim_buf_get_lines(terminal, 0, -1, false), "\n")
      io.stderr:write("TUI test watchdog: child did not respond\n" .. output .. "\n")
      vim.fn.jobstop(job)
    end
  end, 30000)
  local channel
  assert(
    vim.wait(15000, function()
      if not vim.uv.fs_stat(socket) then
        return false
      end
      local ok, value = pcall(vim.fn.sockconnect, "pipe", socket, { rpc = true })
      if ok and value > 0 then
        channel = value
        return true
      end
      return false
    end, 50),
    "TUI did not expose its RPC socket"
  )
  channels[#channels + 1] = channel
  local function eval(code, ...)
    return vim.rpcrequest(channel, "nvim_exec_lua", code, { ... })
  end
  assert(
    vim.wait(15000, function()
      return eval("return vim.v.vim_did_enter == 1")
    end, 50),
    "TUI startup did not finish"
  )
  return eval, channel, job
end

local function text(eval)
  return eval("return table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\\n')")
end

local function check()
  vim.fn.mkdir(project .. "/.git", "p")
  vim.fn.writefile({ "return 42" }, file)
  local eval, channel, job = start()
  assert(
    vim.wait(10000, function()
      return eval("return vim.bo.filetype == 'snacks_dashboard'")
    end, 50),
    "Dashboard did not autostart: " .. eval("return vim.inspect(Snacks.dashboard.status)")
  )

  eval("vim.v.oldfiles = {...}; Snacks.dashboard.update()", file)
  local contents = text(eval)
  for _, label in ipairs({
    "GOFROSHKA",
    "Find file",
    "Open project",
    "Recent files",
    "Projects",
    "Workspace",
    "example.lua",
    "NVF / NIX",
  }) do
    assert(contents:find(label, 1, true), "Missing dashboard content: " .. label)
  end
  assert(eval("return not vim.wo.number and not vim.wo.relativenumber and vim.o.laststatus == 0"))
  assert(eval("return vim.o.columns >= 112"), "Expected the two-column layout")

  vim.fn.jobresize(job, 80, 24)
  assert(
    vim.wait(5000, function()
      return eval("return vim.o.columns == 80") and text(eval):find("N E O V I M", 1, true) ~= nil
    end, 50),
    "Compact layout did not adapt to terminal resize"
  )
  assert(
    eval("return vim.api.nvim_buf_line_count(0) <= vim.api.nvim_win_get_height(0)"),
    "Compact dashboard does not fit"
  )
  assert(text(eval):find("NVF / NIX", 1, true), "Footer disappeared in compact mode")

  vim.rpcrequest(channel, "nvim_input", "f")
  assert(
    vim.wait(5000, function()
      return eval("return #Snacks.picker.get({ source = 'files' }) > 0")
    end, 50),
    "Dashboard file-search shortcut did not open the picker"
  )
  eval("for _, p in ipairs(Snacks.picker.get()) do p:close() end")
  vim.rpcrequest(channel, "nvim_input", "n")
  assert(
    vim.wait(5000, function()
      return eval("return vim.bo.filetype ~= 'snacks_dashboard' and vim.api.nvim_get_mode().mode:sub(1, 1) == 'i'")
    end, 50),
    "Dashboard new-file shortcut failed"
  )
  assert(
    vim.wait(5000, function()
      return eval("return vim.o.laststatus == 3")
    end, 50),
    "Statusline was not restored"
  )
  assert(eval("return vim.wo.number and vim.wo.relativenumber"), "Editor line numbers were not restored")

  local editing = start({ file })
  assert(editing("return vim.api.nvim_buf_get_name(0)") == file)
  assert(
    editing("return vim.bo.filetype == 'lua' and not Snacks.dashboard.status.opened"),
    "Dashboard replaced an explicit file"
  )
  io.stdout:write("PASS: dashboard TUI autostart, history, wide/compact layout, shortcuts and explicit-file startup\n")
end

local ok, err = xpcall(check, debug.traceback)
for _, timer in ipairs(watchdogs) do
  if not timer:is_closing() then
    timer:stop()
    timer:close()
  end
end
for _, channel in ipairs(channels) do
  pcall(vim.fn.chanclose, channel)
end
for _, job in ipairs(jobs) do
  pcall(vim.fn.jobstop, job)
end
vim.fn.jobwait(jobs, 2000)
vim.fn.delete(tmp, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd("cquit 1")
end
