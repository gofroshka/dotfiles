{ inputs, ... }:
let
  editor = { pkgs, ... }: {
    imports = [
      ./settings/editor.nix
      ./settings/ui.nix
      ./settings/languages.nix
    ];
    vim.startPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "zed.nvim";
        version = "6f5e43e";
        src = inputs.zed-theme;
      })
    ];
  };
in
{
  flake.modules.homeManager.neovim = {
    imports = [ inputs.nvf.homeManagerModules.default ];
    programs.nvf = {
      enable = true;
      defaultEditor = true;
      settings.imports = [ editor ];
    };
  };

  perSystem =
    { pkgs, ... }:
    let
      package =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          modules = [ editor ];
        }).neovim;
    in
    {
      packages.neovim = package;
      checks.neovim = pkgs.runCommand "neovim-smoke" { } ''
        export HOME="$TMPDIR/home"
        export XDG_CONFIG_HOME="$HOME/.config" XDG_DATA_HOME="$HOME/.local/share"
        export XDG_STATE_HOME="$HOME/.local/state" XDG_CACHE_HOME="$HOME/.cache"
        mkdir -p "$HOME/project"
        printf 'return 42\n' > "$HOME/project/main.lua"
        cd "$HOME/project"
        ${package}/bin/nvim -n --headless '+lua dofile("${./tests/smoke.lua}")'
        export NVIM_TEST_BINARY="${package}/bin/nvim"
        ${pkgs.neovim-unwrapped}/bin/nvim -n --headless -u NONE -l ${./tests/dashboard.lua}
        touch "$out"
      '';
    };
}
