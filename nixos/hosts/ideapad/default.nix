{ config, inputs, ... }:
{
  flake.nixosConfigurations.ideapad = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./hardware.nix
      config.flake.modules.nixos.base
      config.flake.modules.nixos.home-manager
      config.flake.modules.nixos.device-services
      config.flake.modules.nixos.bluetooth
      config.flake.modules.nixos.niri
      config.flake.modules.nixos.dms
      config.flake.modules.nixos.librepods
      config.flake.modules.nixos.qt
      config.flake.modules.nixos.zsh
      ({ pkgs, ... }: {
        networking.hostName = "ideapad";
        system.stateVersion = "26.05";
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        security.pki.certificateFiles = [ ../../certs/homelab-root-ca.crt ];
        users.users.gofroshka = {
          isNormalUser = true;
          description = "gofroshka";
          extraGroups = [
            "networkmanager"
            "wheel"
            "librepods"
          ];
          shell = pkgs.zsh;
        };
        home-manager.users.gofroshka.imports = [ config.flake.modules.homeManager.gofroshka ];
        home-manager.users.gofroshka.xdg.configFile."niri/host.kdl".text = builtins.readFile ./niri.kdl;
        systemd.user.services.librepods.unitConfig.ConditionUser = "gofroshka";
        services.displayManager = {
          autoLogin = {
            enable = true;
            user = "gofroshka";
          };
          defaultSession = "niri";
          dux-greeter = {
            enable = true;
            compositor.name = "niri";
            configHome = "/home/gofroshka";
          };
        };
      })
    ];
  };
}
