{ lib, ... }:
{
  vim = {
    luaConfigRC.theme = lib.nvim.dag.entryBefore [ "lazyConfigs" "pluginConfigs" ] ''
      vim.cmd.colorscheme("zed-macos-classic-dark")
    '';
    highlight = {
      SnacksDashboardHeader.link = "String";
      SnacksDashboardTitle.link = "Function";
      SnacksDashboardKey.link = "String";
      SnacksDashboardFooter.link = "Comment";
    };
    utility.snacks-nvim = {
      enable = true;
      setupOpts = {
        dashboard = lib.generators.mkLuaInline ''require("work.dashboard").config()'';
        bigfile.enabled = true;
        explorer.enabled = true;
        picker.enabled = true;
        input.enabled = true;
        notifier.enabled = true;
        indent.enabled = true;
        scope.enabled = true;
        statuscolumn.enabled = true;
        words.enabled = true;
      };
    };
    binds.whichKey = {
      enable = true;
      setupOpts.preset = "helix";
    };
    visuals.nvim-web-devicons.enable = true;
    statusline.lualine = {
      enable = true;
      setupOpts = {
        options = {
          theme = "auto";
          globalstatus = true;
          disabled_filetypes.statusline = [ "snacks_dashboard" ];
        };
        sections = {
          lualine_a = [ "mode" ];
          lualine_b = [ "branch" ];
          lualine_c = [
            "diagnostics"
            {
              "@1" = "filename";
              path = 1;
            }
          ];
          lualine_x = [
            "diff"
            "filetype"
          ];
          lualine_y = [ "progress" ];
          lualine_z = [ "location" ];
        };
      };
    };
    tabline.nvimBufferline = {
      enable = true;
      setupOpts.options.always_show_bufferline = false;
    };
    git.gitsigns = {
      enable = true;
      mappings = {
        nextHunk = "]h";
        previousHunk = "[h";
        stageHunk = "<leader>ghs";
        resetHunk = "<leader>ghr";
        previewHunk = "<leader>ghp";
        blameLine = "<leader>ghb";
      };
    };
  };
}
