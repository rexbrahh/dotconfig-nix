# dotconfig-nix

Shared flake for macOS (nix-darwin), NixOS, and standalone Linux + Home Manager setups.

[![CI](https://github.com/rexbrahh/dotconfig-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/rexbrahh/dotconfig-nix/actions/workflows/ci.yml)

## Supported targets
- **macbook (nix-darwin)** – `nix run .#switch` or `./scripts/darwin-switch.sh`. Lives under `hosts/macbook/`.
- **framework (NixOS)** – `sudo nixos-rebuild switch --flake .#framework` or `./scripts/nixos-switch.sh`. Config in `hosts/framework/`.
- **rex@wsl (Home Manager only)** – `home-manager switch --flake .#rex@wsl` or `./scripts/home-switch.sh`. Profile in `hosts/wsl/`.

Add more hosts by copying one of the existing directories and wiring it into `flake.nix`.

## Repository layout
- `flake.nix` – pins nixpkgs, nix-darwin, Home Manager, overlays.
- `hosts/` – per-host system modules (`macbook`, `framework`, `wsl`, ...).
- `modules/` – reusable system + HM modules, split into `common/` and `os/<platform>/`.
- `home/users/rex/` – shared Home Manager profile(s).
- `dotfiles/`, `templates/`, `scripts/`, `secrets/` – supporting assets (Agenix payloads stay encrypted).
- `docs/` – extra notes (`docs/linux.md` explains Linux bootstrap flows).

## Daily commands
- `nix flake check` – evaluate all host outputs (use `--all-systems` to include Linux derivations).
- `nix fmt` / `nix run nixpkgs#treefmt` – format everything (uses Alejandra/Treefmt).
- `nix develop .#default` – enter the lint shell (Statix, Deadnix, shfmt, etc.).
- `./scripts/<target>-switch.sh` – human-friendly wrappers for darwin/nixos/home-manager activates.

## Secrets
Everything in `secrets/` stays encrypted via [Agenix](https://github.com/ryantm/agenix). When adding Linux hosts, remember to append their SSH keys to `secrets/secrets.nix` so they can decrypt.

See `AGENTS.md` plus `docs/linux.md` for deeper guidance.
