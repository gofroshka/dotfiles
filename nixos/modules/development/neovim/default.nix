{ inputs, ... }:
let
  editor = { pkgs, ... }: {
    imports = [
      ./settings/editor.nix
      ./settings/ui.nix
      ./settings/languages.nix
      ./settings/keymaps.nix
      ./settings/dashboard.nix
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
    };
}
