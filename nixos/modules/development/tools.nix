{
  flake.modules.homeManager.development =
    { pkgs, ... }:
    let
      # Codex's recipe bundles native libraries that the new Rust setup hook
      # forces to system versions without declaring their build dependencies.
      # Keep the channel package's vendored build until nixpkgs fixes its recipe.
      codexPackage = pkgs.codex.overrideAttrs {
        dontCargoUseSystemLibs = true;
      };
    in
    {
      home.packages = with pkgs; [
        gcc
        codexPackage
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
