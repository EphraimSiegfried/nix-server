{
  description = "Server Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixarr.url = "github:rasmus-kirk/nixarr";
  };

  outputs = { self, nixpkgs, ... } @ inputs:
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
            ./nixos
          ];
        };
      };

    };
}
