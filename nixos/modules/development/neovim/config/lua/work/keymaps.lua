local tools = require("work.tools")
local M = {}

function M.setup()
  local function map(mode, key, action, desc)
    vim.keymap.set(mode, key, action, { silent = true, desc = desc })
  end
  for _, key in ipairs({ "h", "j", "k", "l" }) do
    map("n", "<C-" .. key .. ">", "<C-w>" .. key, "Window " .. key)
  end
  map("n", "<S-h>", "<cmd>bprevious<cr>", "Previous Buffer")
  map("n", "<S-l>", "<cmd>bnext<cr>", "Next Buffer")
  map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>w<cr><esc>", "Save File")
  map("n", "<esc>", "<cmd>nohlsearch<cr>", "Clear Search")
  map("x", "<", "<gv", "Indent Left")
  map("x", ">", ">gv", "Indent Right")
  map("n", "<leader>qq", "<cmd>qa<cr>", "Quit")
  map("n", "<leader>-", "<C-w>s", "Split Below")
  map("n", "<leader>|", "<C-w>v", "Split Right")
  map("n", "<leader>bd", function()
    Snacks.bufdelete()
  end, "Delete Buffer")
  map("n", "<leader>bo", function()
    Snacks.bufdelete.other()
  end, "Delete Other Buffers")
  map("n", "<leader>e", function()
    Snacks.explorer({ cwd = tools.root() })
  end, "Explorer")
  for key, source in pairs({
    ["<space>"] = "files",
    ff = "files",
    ["/"] = "grep",
    sg = "grep",
    [","] = "buffers",
    fr = "recent",
    sk = "keymaps",
    sh = "help",
    sd = "diagnostics",
    su = "undo",
  }) do
    map("n", "<leader>" .. key, function()
      Snacks.picker[source]({ cwd = tools.root() })
    end, source)
  end
  map({ "n", "x" }, "<leader>sw", function()
    Snacks.picker.grep_word({ cwd = tools.root() })
  end, "Search Word / Selection")
  map("n", "<leader>gg", function()
    Snacks.lazygit({ cwd = tools.root() })
  end, "Lazygit")
  map("n", "<leader>ft", function()
    Snacks.terminal(nil, { cwd = tools.root() })
  end, "Terminal")
  map({ "n", "t" }, "<C-/>", function()
    Snacks.terminal.toggle(nil, { cwd = tools.root() })
  end, "Terminal")
  map({ "n", "t" }, "<C-_>", function()
    Snacks.terminal.toggle(nil, { cwd = tools.root() })
  end, "Terminal")
  map("t", "<Esc><Esc>", "<C-\\><C-n>", "Normal Mode")
  map({ "n", "x" }, "<leader>cf", function()
    require("conform").format()
  end, "Format")
  map("n", "<leader>uD", function()
    Snacks.dashboard()
  end, "Start Screen")
  Snacks.toggle({
    name = "Auto Format",
    get = function()
      return vim.g.autoformat ~= false
    end,
    set = function(value)
      vim.g.autoformat = value
    end,
  }):map("<leader>uf")
  Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
  Snacks.toggle.inlay_hints():map("<leader>uh")
  require("which-key").add({
    { "<leader>b", group = "buffers" },
    { "<leader>c", group = "code" },
    { "<leader>f", group = "files" },
    { "<leader>g", group = "git" },
    { "<leader>s", group = "search" },
    { "<leader>u", group = "toggles" },
  })
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("work_editor", { clear = true }),
    callback = function()
      vim.hl.on_yank()
    end,
  })
  vim.api.nvim_create_user_command("Tools", function()
    local lines = { "Nix / devenv tools", "Root: " .. tools.root(), "" }
    local servers = require("work.lsp").servers
    for _, name in ipairs(vim.fn.sort(vim.tbl_keys(servers))) do
      lines[#lines + 1] = name .. ": " .. servers[name]
    end
    vim.cmd.new()
    vim.bo.buftype, vim.bo.bufhidden, vim.bo.swapfile = "nofile", "wipe", false
    vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
    vim.bo.modifiable = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true })
  end, { desc = "Show project language-server paths" })
end

return M
