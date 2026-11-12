let
  dfilesPackage =
    pkgs:
    pkgs.dux-files.overrideAttrs (old: {
      # Dialogs share the main window's app-id. Tag them before sync-shell embeds
      # the QML so Niri can float only file choosers, regardless of their title.
      postPatch = ''
        substituteInPlace quickshell/Modules/ChooserWindow.qml \
          --replace-fail \
            'title: (request?.title ?? "") !== "" ? request.title : defaultTitle' \
            'title: ((request?.title ?? "") !== "" ? request.title : defaultTitle) + " — Dux File Chooser"'
      ''
      + (old.postPatch or "");
    });
  dmsPackage =
    pkgs:
    pkgs.dux-shell.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        chmod -R u+w ../quickshell
        patch -d ../quickshell -p1 < ${../../../patches/dms-airpods-control-center.patch}
      '';
    });
  quickshellPackage =
    pkgs:
    pkgs.quickshell.overrideAttrs (old: {
      buildInputs = (old.buildInputs or [ ]) ++ [ pkgs.qt6.qtwebsockets ];
    });
in
{
  flake.modules.nixos.dms = { lib, pkgs, ... }: {
    programs.dux-shell = {
      enable = true;
      package = dmsPackage pkgs;
      quickshell.package = quickshellPackage pkgs;
    };
    programs.dux-files = {
      enable = true;
      package = dfilesPackage pkgs;
      portal.enable = true;
    };
    # portal.enable installs the vendor unit; the module's systemd.enable would
    # add another ExecStart in a drop-in and make the service invalid.
    systemd.user.services.dfiles = {
      wantedBy = [ "graphical-session.target" ];
      enableDefaultPath = false;
    };
    xdg = {
      mime.defaultApplications = lib.genAttrs [
        "inode/directory"
        "x-scheme-handler/trash"
        "x-scheme-handler/sftp"
        "x-scheme-handler/smb"
      ] (_: [ "dev.duxlabs.files.desktop" ]);
      portal.config = {
        common."org.freedesktop.impl.portal.FileChooser" = [ "dfiles" ];
        # Niri supplies its own desktop-specific config, which takes precedence.
        niri."org.freedesktop.impl.portal.FileChooser" = lib.mkForce [ "dfiles" ];
      };
    };
    systemd.user.services.dms.environment.DMS_HIDE_TRAYIDS = "librepods";
  };

  # Import only at the standalone composition point. On NixOS the system module
  # above owns installation and the vendor user service, avoiding two owners.
  flake.modules.homeManager.dms =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      home.packages = [
        (dmsPackage pkgs)
        (quickshellPackage pkgs)
        pkgs.matugen
        pkgs.cava
        (dfilesPackage pkgs)
      ];
      systemd.user.services.dms = {
        Unit = {
          Description = "Dux Shell (DMS)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };
        Service = {
          Type = "notify";
          NotifyAccess = "main";
          Environment = [
            "QS_DISABLE_CRASH_HANDLER=1"
            "DMS_HIDE_TRAYIDS=librepods"
            "PATH=${lib.makeBinPath [ config.home.path ]}:/usr/bin:/bin"
          ];
          ExecStart = "${dmsPackage pkgs}/bin/dms run --session";
          ExecReload = "${pkgs.coreutils}/bin/kill -USR1 $MAINPID";
          Restart = "on-failure";
          RestartSec = "1.23";
          TimeoutStartSec = "90s";
          TimeoutStopSec = 10;
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };
    };
}
