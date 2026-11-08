{
  flake.modules.nixos.librepods = {
    programs.librepods.enable = true;
    nixpkgs.overlays = [
      (_final: prev: {
        librepods = prev.librepods.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            ../../patches/librepods-prefer-aac.patch
            ../../patches/librepods-sync-noise-menu.patch
            ../../patches/librepods-rediscover-audio-card.patch
          ];
        });
      })
    ];
    systemd.user.services.librepods = {
      description = "LibrePods AirPods integration";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "/run/wrappers/bin/sg librepods -c '/run/wrappers/bin/librepods --hide'";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
