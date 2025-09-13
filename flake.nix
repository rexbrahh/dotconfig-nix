{
  description = "macOS managed with nix-darwin + Home Manager (flakes)";

  # Optional: declare extra binary caches here if you explicitly trust them.
  # Keeping this empty reduces supply-chain trust expansion. Prefer
  # per-user nix.conf if you want third-party caches.

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

    # Manage the Homebrew installation declaratively
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Secrets management (age/agenix scaffold)
    agenix.url = "github:ryantm/agenix";

    # Stable channel for selective pinning alongside unstable
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      darwin,
      home-manager,
      nix-index-database,
      nix-homebrew,
      agenix,
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
          # Overlay: expose `pkgs.stable` from nixpkgs-stable while base = nixpkgs (unstable)
          ({ ... }: {
            nixpkgs.overlays = [
              # Your local overlay (overrides go here)
              (import ./overlays/default.nix)
              # Add stable channel under pkgs.stable
              (final: prev:
                let stable = import inputs."nixpkgs-stable" { inherit (prev) system; config = prev.config; };
                in { stable = stable; }
              )
            ];
          })
          # Install & manage Homebrew itself (pinned)
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true; # on Apple Silicon, also install Intel prefix
              autoMigrate = true;   # migrate an existing install if found
              user = "rexliu";
              # Declarative taps are optional; leave empty to avoid brew warnings
              taps = { };
            };
          }
          # Enable Home Manager as a nix-darwin module
          home-manager.darwinModules.home-manager

          # Host-specific configuration (imports HM user modules inside)
          ./hosts/macbook/darwin-configuration.nix

          # nix-index with prebuilt DB (+ optional comma wrapper)
          nix-index-database.darwinModules.nix-index

          # Agenix secrets module (scaffold; define secrets in ./secrets)
          agenix.darwinModules.default

          # Linux builder (speed up Linux builds from macOS)
          ({ ... }: { nix.linux-builder.enable = true; })

          # Optional: share nix-index database
          # programs.nix-index-database.comma.enable = true;
        ];
      };

      # Convenience: `nix run .#switch`
      apps.${system}.switch = {
        type = "app";
        program = "${pkgs.writeShellScriptBin "switch" ''
          set -euo pipefail
          darwin-rebuild switch --flake ${self}
        ''}/bin/switch";
        meta = {
          description = "Activate the macbook nix-darwin configuration";
        };
      };

      # Quick formatter for this repo (nix only)
      formatter.${system} = pkgs.alejandra;

      # Dev shells
      devShells.${system} = {
        # Formatters & linters used by pre-commit
        default = pkgs.mkShell {
          packages = with pkgs; [
            alejandra
            statix
            deadnix
            treefmt
            shfmt
            stylua
            taplo
            yamlfmt
            jq
            pre-commit
          ];
        };

        # K8s/microservices shell: `nix develop .#k8s`
        k8s = pkgs.mkShell {
          packages = with pkgs; [
            kind kubectl kubernetes-helm kustomize skaffold tilt k9s dive
          ];
          shellHook = ''
            export KIND_CLUSTER_NAME=dev
            alias kind-up='kind create cluster --name "$KIND_CLUSTER_NAME" --wait 120s'
            alias kind-down='kind delete cluster --name "$KIND_CLUSTER_NAME"'
            alias kctx='kubectx'
            alias kns='kubens'
            alias k='kubectl'
            alias klogs='kubectl logs -f'
          '';
        };

        # DB tooling shell: `nix develop .#db`
        db = pkgs.mkShell {
          packages = with pkgs; [
            postgresql pgcli sqlite litecli redis mongosh
          ];
          shellHook = ''
            alias pg-cli='psql "$PGURL"'
            alias pg-local='PGURL=postgres://postgres:postgres@localhost:5432/postgres pg-cli'
            alias redis-cli-local='redis-cli -u redis://localhost:6379'
            echo "Tip: use 'pg-local' or set PGURL to point at your DB."
          '';
        };
      };
    };
}
