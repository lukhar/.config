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
    { nixpkgs, nix-darwin, home-manager, nixos-hardware, zen-browser, ... }:
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
            # rename whatever is in the way of a link to *.hm-bak instead of failing
            home-manager.backupFileExtension = "hm-bak";
            home-manager.users.lharatym = import ./modules/home;
          }
        ];
      };

      # The Framework laptop. hosts/framework/default.nix started as the
      # configuration.nix from the install -- it is already a valid module -- and
      # it imports its own hardware-configuration.nix, which has to be generated
      # on the machine and committed from there.
      nixosConfigurations.framework = nixpkgs.lib.nixosSystem {
        modules = [
          ./hosts/framework
          # Framework 13, Core Ultra X7 358H (Panther Lake)
          nixos-hardware.nixosModules.framework-intel-core-ultra-series3
          { environment.systemPackages = [ zen-browser.packages.x86_64-linux.default ]; }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # rename whatever is in the way of a link to *.hm-bak instead of failing
            # (e.g. the ~/.config/hypr hyprland generates on its first start)
            home-manager.backupFileExtension = "hm-bak";
            home-manager.users.lukhar = import ./modules/home;
          }
        ];
      };
    };
}
