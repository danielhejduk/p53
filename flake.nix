{
  description = "ThinkPad P53 NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations.p53 = nixpkgs.lib.nixosSystem {
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/p53
      ];
    };
  };
}
