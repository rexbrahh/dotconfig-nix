# dotconfig-nix

Shared flake for macOS (nix-darwin), NixOS, and standalone Linux + Home Manager setups.

[![CI](https://github.com/rexbrahh/dotconfig-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/rexbrahh/dotconfig-nix/actions/workflows/ci.yml)

## Supported targets
- **macbook (nix-darwin)** – `nix run .#switch` or `./scripts/darwin-switch.sh`. Lives under `hosts/macbook/`.
- **nixos-vm-m4 (NixOS VM)** – `sudo nixos-rebuild switch --flake .#nixos-vm-m4` or `./scripts/nixos-switch.sh`. Config in `hosts/nixos-vm-m4/`.
- **server@ubuntu (Home Manager only)** – `home-manager switch --flake .#server@ubuntu` or `./scripts/home-switch.sh`. Profile in `hosts/server-ubuntu/`.
  - Create `hosts/server-ubuntu/local.nix` (gitignored) to override the real username/home dir before running on your server.

Add more hosts by copying one of the existing directories and wiring it into `flake.nix`.

## Repository layout
- `flake.nix` – pins nixpkgs, nix-darwin, Home Manager, overlays.
- `hosts/` – per-host system modules (`macbook`, `nixos-vm-m4`, `server-ubuntu`, ...).
- `modules/` – reusable system + HM modules, split into `common/` and `os/<platform>/`.
- `home/users/rex/` – shared Home Manager profile(s).
- `dotfiles/`, `templates/`, `scripts/`, `secrets/` – supporting assets (Agenix payloads stay encrypted).
- `docs/` – extra notes (`docs/linux.md` for Linux targets, `docs/nixos-vm-m4.md` for the VM bootstrap).

## Daily commands
- `nix flake check` – evaluate all host outputs (use `--all-systems` to include Linux derivations).
- `nix fmt` – runs treefmt using `treefmt.toml` (or invoke `treefmt` manually).
- `nix develop .#default` – enter the lint shell (Statix, Deadnix, shfmt, etc.).
- `./scripts/<target>-switch.sh` – human-friendly wrappers for darwin/nixos/home-manager activates.

## Secrets
Everything in `secrets/` stays encrypted via [Agenix](https://github.com/ryantm/agenix). When adding Linux hosts, remember to append their SSH keys to `secrets/secrets.nix` so they can decrypt.

See `AGENTS.md` plus `docs/linux.md` for deeper guidance.
