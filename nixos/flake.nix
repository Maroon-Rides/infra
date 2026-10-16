{
  description = "MaroonRides NixOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-26.05";
    disko.url = "github:nix-community/disko";
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-stable,
      disko,
      ...
    }:
    let
      utils = import ./lib/utils.nix { inherit nixpkgs nixpkgs-stable; };
      inherit (utils) mkHost;
    in
    {
      nixosConfigurations.prod-server = mkHost {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./hosts/prod-server/configuration.nix
        ];
      };
    };
}
