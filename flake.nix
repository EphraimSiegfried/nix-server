{
  description = "Server Configuration";

  inputs = {
    nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixarr = {
      url = "github:rasmus-kirk/nixarr";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    lunch-basel.url = "github:EphraimSiegfried/lunch-basel";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        ares = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          modules = [
            inputs.disko.nixosModules.disko
            inputs.nixarr.nixosModules.default
            inputs.lunch-basel.nixosModules.default
            ./nixos
          ];
        };
      };

    };
}
