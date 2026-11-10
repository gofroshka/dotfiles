{ ... }:
let
  map = mode: key: action: desc: {
    inherit
      mode
      key
      action
      desc
      ;
  };
  command = code: "<cmd>lua ${code}<cr>";
  root = "Snacks.git.get_root()";
  picker = source: command "Snacks.picker.${source}({ cwd = ${root} })";
in
{
  vim = {
    keymaps =
      builtins.map (key: map "n" "<C-${key}>" "<C-w>${key}" "Window ${key}") [
        "h"
        "j"
        "k"
        "l"
      ]
      ++ [
        (map "n" "<S-h>" "<cmd>BufferLineCyclePrev<cr>" "Previous Buffer")
        (map "n" "<S-l>" "<cmd>BufferLineCycleNext<cr>" "Next Buffer")
        (map [ "n" "i" "x" "s" ] "<C-s>" "<cmd>w<cr><esc>" "Save File")
        (map "n" "<esc>" "<cmd>nohlsearch<cr>" "Clear Search")
        (map "x" "<" "<gv" "Indent Left")
        (map "x" ">" ">gv" "Indent Right")
        (map "n" "<leader>qq" "<cmd>qa<cr>" "Quit")
        (map "n" "<leader>-" "<C-w>s" "Split Below")
        (map "n" "<leader>|" "<C-w>v" "Split Right")
        (map "n" "<leader>bd" (command "Snacks.bufdelete()") "Delete Buffer")
        (map "n" "<leader>bo" (command "Snacks.bufdelete.other()") "Delete Other Buffers")
        (map "n" "<leader>e" (command "Snacks.explorer({ cwd = ${root} })") "Explorer")
        (map "n" "<leader><space>" (picker "files") "Find Files")
        (map "n" "<leader>ff" (picker "files") "Find Files")
        (map "n" "<leader>/" (picker "grep") "Find Text")
        (map "n" "<leader>sg" (picker "grep") "Find Text")
        (map "n" "<leader>," (picker "buffers") "Buffers")
        (map "n" "<leader>fr" (picker "recent") "Recent Files")
        (map "n" "<leader>sk" (picker "keymaps") "Keymaps")
        (map "n" "<leader>sh" (picker "help") "Help")
        (map "n" "<leader>sd" (picker "diagnostics") "Diagnostics")
        (map "n" "<leader>su" (picker "undo") "Undo History")
        (map [ "n" "x" ] "<leader>sw" (picker "grep_word") "Search Word / Selection")
        (map "n" "<leader>gg" (command "Snacks.lazygit({ cwd = ${root} })") "Lazygit")
        (map "n" "<leader>ft" (command "Snacks.terminal(nil, { cwd = ${root} })") "Terminal")
        (map [ "n" "t" ] "<C-/>" (command "Snacks.terminal.toggle(nil, { cwd = ${root} })") "Terminal")
        (map [ "n" "t" ] "<C-_>" (command "Snacks.terminal.toggle(nil, { cwd = ${root} })") "Terminal")
        (map "t" "<Esc><Esc>" "<C-\\><C-n>" "Normal Mode")
        (map [ "n" "x" ] "<leader>cf" (command ''require("conform").format()'') "Format")
        (map "n" "<leader>cl" "<cmd>checkhealth vim.lsp<cr>" "LSP Info")
        (map "n" "<leader>uD" (command "Snacks.dashboard()") "Start Screen")
        (map "n" "<leader>uf" "<cmd>let g:nvf_format_save = g:nvf_format_save ? v:false : v:true<cr>"
          "Toggle Auto Format"
        )
        (map "n" "<leader>uw" "<cmd>setlocal wrap!<cr>" "Toggle Wrap")
        (map "n" "<leader>uh"
          (command "vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })")
          "Toggle Inlay Hints"
        )
      ];
    lsp.mappings = {
      goToDefinition = "gd";
      goToDeclaration = "gD";
      goToType = "gy";
      listImplementations = "gI";
      listReferences = "gr";
      nextDiagnostic = "]d";
      previousDiagnostic = "[d";
      openDiagnosticFloat = "<leader>cd";
      hover = "K";
      signatureHelp = "gK";
      renameSymbol = "<leader>cr";
      codeAction = "<leader>ca";
      listDocumentSymbols = "<leader>ss";
      listWorkspaceSymbols = "<leader>sS";
      format = null; # The global Conform binding also works without an LSP.
      toggleFormatOnSave = null;
    };
    binds.whichKey.setupOpts.spec = [
      {
        "@1" = "<leader>b";
        group = "buffers";
      }
      {
        "@1" = "<leader>c";
        group = "code";
      }
      {
        "@1" = "<leader>f";
        group = "files";
      }
      {
        "@1" = "<leader>g";
        group = "git";
      }
      {
        "@1" = "<leader>s";
        group = "search";
      }
      {
        "@1" = "<leader>u";
        group = "toggles";
      }
    ];
    autocmds = [
      {
        event = [ "LspAttach" ];
        desc = "Signature help in LSP buffers";
        command = "inoremap <buffer> <silent> <C-k> <Cmd>lua vim.lsp.buf.signature_help()<CR>";
      }
      {
        event = [ "LspAttach" ];
        desc = "Code actions for a selection";
        command = "xnoremap <buffer> <silent> <leader>ca <Cmd>lua vim.lsp.buf.code_action()<CR>";
      }
    ];
  };
}
