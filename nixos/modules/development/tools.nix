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

      # Temporary fix for https://github.com/NixOS/nixpkgs/pull/585196.
      # Match the tested recipe's input order to reuse its existing build;
      # retain other inputs and leave newer channel versions untouched.
      gooseCliPackage =
        if pkgs.goose-cli.version == "1.55.0" then
          pkgs.goose-cli.overrideAttrs (old: {
            buildInputs = pkgs.lib.unique (
              (with pkgs; [
                aws-lc
                dbus
                oniguruma
                openssl
                sqlite
                zstd
              ])
              ++ (old.buildInputs or [ ])
            );
          })
        else
          pkgs.goose-cli;
      gooseDesktopPackage = pkgs.goose-desktop.override {
        goose-cli = gooseCliPackage;
      };
    in
    {
      home.packages = with pkgs; [
        gcc
        codexPackage
        opencode
        gooseCliPackage
        gooseDesktopPackage
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
