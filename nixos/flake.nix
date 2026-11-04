{

  description = "My NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    {
      nixosConfigurations = {
        gofronix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules/hardware.nix
            ./modules/system.nix
            ./modules/programs.nix
            ./modules/appearance.nix
            ./modules/audio.nix
            ./modules/services.nix
            ./modules/shell.nix
          ];
        };
      };
    };

}
