{
  # LibrePods otherwise overrides WirePlumber's AAC choice with SBC-XQ.
  # Keep the fallback codecs available instead of disabling them globally.
  nixpkgs.overlays = [
    (_final: prev: {
      librepods = prev.librepods.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ../patches/librepods-prefer-aac.patch
          ../patches/librepods-sync-noise-menu.patch
        ];
      });
    })
  ];

  systemd.user.services.librepods = {
    description = "LibrePods AirPods integration";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    unitConfig.ConditionUser = "gofroshka";
    serviceConfig = {
      # Also works in sessions started before the librepods group was added.
      ExecStart = "/run/wrappers/bin/sg librepods -c '/run/wrappers/bin/librepods --hide'";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
