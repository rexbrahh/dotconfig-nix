{
  description = "macOS managed with nix-darwin + Home Manager (flakes)";

  inputs = {
    # Pick a channel you like; “nixpkgs-unstable” gives newest packages.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nix-darwin: declarative macOS (system-level) management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Home Manager: user-level packages & dotfiles; integrate via nix-darwin module
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Optional: nix-index prebuilt DB for fast `nix-locate`
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      darwin,
      home-manager,
      nix-index-database,
      ...
    }:
    let
      # Helper for Intel vs Apple Silicon
      system = "aarch64-darwin"; # use "x86_64-darwin" for Intel Macs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # --- nix-darwin host(s) ---
      darwinConfigurations."macbook" = darwin.lib.darwinSystem {
        inherit system;
        modules = [
          # Core nix-darwin config
          ./hosts/macbook/darwin-configuration.nix
          #./hosts/default.nix
          # Let nix-darwin enable Home Manager as a module
          home-manager.darwinModules.home-manager

          # Wire in Home Manager for the primary user
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."rexliu" = import ./hosts/macbook/home.nix;

            # Optional: share nix-index database
            imports = [ nix-index-database.darwinModules.nix-index ];
            programs.nix-index-database.comma.enable = true;
          }
        ];
      };

      # Convenience: `nix run .#switch`
      apps.${system}.switch = {
        type = "app";
        program = "${pkgs.writeShellScriptBin "switch" ''
          set -euo pipefail
          darwin-rebuild switch --flake ${self}
        ''}/bin/switch";
      };
    };
}
