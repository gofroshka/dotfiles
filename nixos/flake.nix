{

  description = "My NixOS Config";
  
  inputs = {
  	nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {self, nixpkgs, ...}@inputs: {
    nixosConfigurations = {
      gofronix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
	modules = [
	  ./modules/hardware-configuration.nix
	  ./modules/configuration.nix
	  ./modules/programs.nix
	];
      };	
    };
  };

}
