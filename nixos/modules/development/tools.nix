{
  flake.modules.homeManager.development = { pkgs, ... }: {
    home.packages = with pkgs; [
      gcc
      codex
      opencode
      tree-sitter
      deadnix
      nil
      nixfmt
      statix
      lua-language-server
      stylua
      markdownlint-cli2
    ];
  };
}
