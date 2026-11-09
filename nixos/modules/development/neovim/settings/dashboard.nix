{
  vim.utility.snacks-nvim.setupOpts.dashboard = {
    enabled = true;
    width = 52;
    pane_gap = 8;
    preset = {
      header = ''
        ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
        ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
        ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
        ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
        ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
        ╚═╝  ╚═══╝╚══════╝ ╚═════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝'';
      keys = [
        {
          icon = " ";
          key = "f";
          desc = "Find file";
          action = ":lua Snacks.picker.files()";
        }
        {
          icon = " ";
          key = "n";
          desc = "New file";
          action = ":ene | startinsert";
        }
        {
          icon = " ";
          key = "g";
          desc = "Find text";
          action = ":lua Snacks.picker.grep()";
        }
        {
          icon = " ";
          key = "r";
          desc = "Recent files";
          action = ":lua Snacks.picker.recent()";
        }
        {
          icon = " ";
          key = "p";
          desc = "Open project";
          action = ":lua Snacks.picker.projects({ dev = { '~/Projects' } })";
        }
        {
          icon = "󰙅 ";
          key = "e";
          desc = "Explorer";
          action = ":lua Snacks.explorer()";
        }
        {
          icon = "󰒓 ";
          key = "t";
          desc = "LSP Info";
          action = ":checkhealth vim.lsp";
        }
        {
          icon = " ";
          key = "q";
          desc = "Quit";
          action = ":qa";
        }
      ];
    };
    sections = [
      {
        section = "header";
        padding = 1;
      }
      {
        section = "keys";
        padding = 1;
      }
      {
        section = "recent_files";
        title = "Recent files";
        icon = " ";
        pane = 2;
        indent = 2;
        limit = 2;
      }
      {
        section = "projects";
        title = "Projects";
        icon = " ";
        pane = 2;
        indent = 2;
        limit = 2;
        session = false;
      }
      { footer = "GOFROSHKA  ·  NVF / NIX"; }
    ];
  };
}
