{
  description = "My macOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    #nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
   #nix-darwin.inputs.nixpkgs.follows = "nixpkgs"; 
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, ... }: {
    # This is the part that fixes the error
    darwinConfigurations."Rexs-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Or "x86_64-darwin" for Intel Macs
      modules = [
        # 1. Your main system configuration
        ./darwin-configuration.nix

        # 2. Your user configuration via Home Manager
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          # Make sure 'rexliu' is your actual macOS username
          home-manager.users.rexliu = import ./home.nix;
        }
      ];
      specialArgs = { inherit inputs; };
    };
  };
}
