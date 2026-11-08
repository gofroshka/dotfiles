{
  flake.modules.homeManager.neovim =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      # Preserve the existing LazyVim setup; don't introduce HM's plugin manager.
      home.packages = [ pkgs.neovim ];
      xdg.configFile."nvim" = {
        source = ./config;
        recursive = true;
      };

      # LazyVim writes both files. Seed them only once; never make them store links.
      home.activation.seedNeovimState = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        for name in lazy-lock.json lazyvim.json; do
          target=${lib.escapeShellArg "${config.xdg.configHome}/nvim"}/"$name"
          if [ ! -e "$target" ] && [ ! -L "$target" ]; then
            run install -Dm644 ${./defaults}/"$name" "$target"
          fi
        done
      '';
    };
}
