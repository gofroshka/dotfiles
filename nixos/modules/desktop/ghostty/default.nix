{
  flake.modules.homeManager.ghostty =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = [ pkgs.ghostty ];
      xdg.configFile."ghostty/config.ghostty".source = ./config.ghostty;

      # No palette is pinned. A blank, writable first-run theme avoids a missing
      # theme error until DMS generates colors; existing themes are never changed.
      home.activation.seedGhosttyTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        target=${lib.escapeShellArg "${config.xdg.configHome}/ghostty/themes/dankcolors"}
        if [ ! -e "$target" ] && [ ! -L "$target" ]; then
          run install -Dm644 ${pkgs.writeText "ghostty-theme-placeholder" "# Generated colors belong to DMS.\n"} "$target"
        fi
      '';
    };
}
