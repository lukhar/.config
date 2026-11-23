{
  description = "lukhar's machines: a work Mac (fruitbox), a NixOS Framework laptop, and piecyk (Arch, no nix)";

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

    # per-model quirks: kernel params, firmware, audio, the framework EC module
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # zen browser is not in nixpkgs; this is the community-maintained flake
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      # The same home-manager setup on every nix host; only the user differs.
      homeFor = user: {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        # rename whatever is in the way of a link to *.hm-bak instead of failing
        # (e.g. the ~/.config/hypr hyprland generates on its first start)
        home-manager.backupFileExtension = "hm-bak";
        home-manager.users.${user} = import ./modules/home;
      };
    in
    {
      # The attribute name, not the hostname: Jamf reverts this Mac's name to its
      # asset tag, so selection is explicit -- darwin-rebuild switch --flake .#fruitbox
      darwinConfigurations.fruitbox = nix-darwin.lib.darwinSystem {
        modules = [
          ./hosts/fruitbox
          home-manager.darwinModules.home-manager
          (homeFor "lharatym")
        ];
      };

      # The Framework laptop. Its own inputs (nixos-hardware, zen) are imported
      # by hosts/framework, which gets them through specialArgs.
      nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/framework
          home-manager.nixosModules.home-manager
          (homeFor "lukhar")
        ];
      };

      # nix fmt: formats every .nix file in the repo
      formatter = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ] (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );
    };
}
