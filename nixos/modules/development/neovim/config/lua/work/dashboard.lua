local M = {}

local function list(title, icon, items, pane)
  local section = { title = title, icon = icon, pane = pane, indent = 2, padding = 1 }
  return vim.list_extend(section, #items > 0 and items or { { text = { "Nothing here yet", hl = "Comment" } } })
end

function M.config()
  return {
    enabled = true,
    width = 52,
    pane_gap = 8,
    preset = {
      header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      keys = {
        {
          icon = " ",
          key = "f",
          desc = "Find file",
          action = function()
            Snacks.picker.files()
          end,
        },
        { icon = " ", key = "n", desc = "New file", action = ":ene | startinsert" },
        {
          icon = " ",
          key = "g",
          desc = "Find text",
          action = function()
            Snacks.picker.grep()
          end,
        },
        {
          icon = " ",
          key = "r",
          desc = "Recent files",
          action = function()
            Snacks.picker.recent()
          end,
        },
        {
          icon = " ",
          key = "p",
          desc = "Open project",
          action = function()
            Snacks.picker.projects({ dev = { "~/Projects" } })
          end,
        },
        {
          icon = "󰙅 ",
          key = "e",
          desc = "Explorer",
          action = function()
            Snacks.explorer()
          end,
        },
        { icon = "󰒓 ", key = "t", desc = "Project tools", action = ":Tools" },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = function(self)
      local size = self:size()
      local wide = size.width >= 112
      local compact = not wide and size.height < 35
      local pane = wide and 2 or 1
      local files = Snacks.dashboard.sections.recent_files({ limit = compact and 2 or 5 })(self)
      local projects = Snacks.dashboard.sections.projects({
        limit = compact and 1 or 3,
        action = function(dir)
          vim.fn.chdir(dir)
          Snacks.picker.files({ cwd = dir })
        end,
      })
      local version = vim.version()
      local cwd = vim.fn.fnamemodify(vim.uv.cwd(), ":~")
      return {
        { header = compact and "N E O V I M" or self.opts.preset.header, padding = 1 },
        {
          text = { { "GOFROSHKA", hl = "Special" }, { "  /  NIX WORKSPACE", hl = "Comment" } },
          align = "center",
          padding = 1,
        },
        { section = "keys", padding = 1 },
        list("Recent files", " ", files, pane),
        list("Projects", " ", projects, pane),
        compact and {
          text = {
            vim.env.DEVENV_ROOT and "● devenv active" or "○ global environment",
            hl = vim.env.DEVENV_ROOT and "String" or "Comment",
          },
          align = "center",
        } or {
          pane = pane,
          title = "Workspace",
          icon = " ",
          indent = 2,
          { text = { vim.fn.pathshorten(cwd), hl = "Comment" } },
          {
            text = {
              vim.env.DEVENV_ROOT and "● devenv active" or "○ global environment",
              hl = vim.env.DEVENV_ROOT and "String" or "Comment",
            },
          },
        },
        {
          footer = ("NVIM %d.%d.%d  ·  NVF / NIX"):format(version.major, version.minor, version.patch),
          padding = { 0, 1 },
        },
      }
    end,
  }
end

return M
