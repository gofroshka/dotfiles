{
  flake.modules.homeManager.ghostty =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.ghostty = {
        enable = true;

        settings = {
          theme = "dankcolors";
          app-notifications = false;
          resize-overlay = "never";
          window-decoration = "none";
          gtk-tabs-location = "hidden";
          confirm-close-surface = false;
          working-directory = "home";
          window-inherit-working-directory = false;
        };

      };
    };
}
