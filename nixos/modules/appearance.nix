{
  # Keep LibrePods available over D-Bus, but omit its icon from all tray lists.
  systemd.user.services.dms.environment.DMS_HIDE_TRAYIDS = "librepods";

  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };
}
