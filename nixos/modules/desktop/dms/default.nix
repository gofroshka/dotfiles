let
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
  flake.modules.nixos.dms = { pkgs, ... }: {
    programs.dux-shell = {
      enable = true;
      package = dmsPackage pkgs;
      quickshell.package = quickshellPackage pkgs;
    };
    programs.dux-files = {
      enable = true;
      systemd.enable = true;
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
        pkgs.dux-files
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
