{ inputs, ... }:
{
  flake.modules.nixos.home-manager = {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      # Preserve pre-HM static files on the first authorized activation.
      # Existing backups cause an error instead of being overwritten.
      backupFileExtension = "before-home-manager";
    };
  };

  flake.modules.homeManager.safe-config = { config, lib, ... }: {
    home.activation.checkConfigDirectory = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      if [ -L ${lib.escapeShellArg config.xdg.configHome} ]; then
        echo "Refusing Home Manager activation: the config root is a symlink." >&2
        echo "Back up and detach ~/.config first; see README.md." >&2
        exit 1
      fi
    '';
  };
}
