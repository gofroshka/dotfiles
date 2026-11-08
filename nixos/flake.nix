{

  description = "My NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts/ea2630b7470978622c7689a1ff75d2b389175399";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/095fef2f265c3c0da4fe315efba8f8a04495ab34";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      perSystem = { pkgs, ... }: {
        formatter = pkgs.nixfmt;
      };
      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.home-manager.flakeModules.home-manager
        ./modules/core/system.nix
        ./modules/core/home-manager.nix
        ./modules/core/device-services.nix
        ./modules/core/bluetooth.nix
        ./modules/cli/zsh.nix
        ./modules/cli/tools.nix
        ./modules/cli/zellij
        ./modules/development/tools.nix
        ./modules/development/neovim
        ./modules/desktop/niri
        ./modules/desktop/ghostty
        ./modules/desktop/applications.nix
        ./modules/desktop/dms
        ./modules/desktop/librepods.nix
        ./modules/desktop/qt.nix
        ./hosts/ideapad
        ./users/gofroshka.nix
      ];
    };

}
