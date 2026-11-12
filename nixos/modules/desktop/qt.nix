{
  flake.modules.nixos.qt = {
    qt.enable = true;
    environment.variables = {
      # Use the configured FileChooser portal instead of toolkit-owned dialogs.
      GTK_USE_PORTAL = "1";
      QT_QPA_PLATFORMTHEME = "xdgdesktopportal";
      # Telegram selects its Qt 6 platform theme using this variable.
      QT_QPA_PLATFORMTHEME_QT6 = "xdgdesktopportal";
    };
  };
}
