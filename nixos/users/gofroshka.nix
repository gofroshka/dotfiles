{ config, inputs, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.gofroshka = {
    imports = [
      hm.safe-config
      hm.zsh
      hm.git
      hm.cli-tools
      hm.development
      hm.neovim
      hm.niri
      hm.ghostty
      hm.zellij
      hm.desktop-apps
    ];
    home = {
      username = "gofroshka";
      homeDirectory = "/home/gofroshka";
      # First Home Manager deployment; independent of the nixpkgs release.
      stateVersion = "26.05";
    };
  };

  flake.homeConfigurations."gofroshka@linux" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    modules = [
      hm.gofroshka
      hm.dms
      ({ lib, pkgs, ... }: {
        targets.genericLinux.enable = true;
        programs.home-manager.enable = true;
        home.packages = [ pkgs.niri ];
        home.activation.checkStandalonePlatform = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          if [ -e /etc/NIXOS ]; then
            echo "On NixOS use nixos-rebuild, not the standalone Home Manager output." >&2
            exit 1
          fi
        '';
      })
    ];
  };
}
