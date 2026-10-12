{
  description = "lukhar's machines: a work Mac, piecyk (Arch), and a NixOS laptop to come";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nix-darwin, home-manager, ... }:
    {
      # The attribute name, not the hostname: Jamf reverts this Mac's name to its
      # asset tag, so selection is explicit -- darwin-rebuild switch --flake .#fruitbox
      darwinConfigurations.fruitbox = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/fruitbox
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lharatym = import ./modules/home;
          }
        ];
      };
    };
}
