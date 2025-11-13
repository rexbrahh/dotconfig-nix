# Linux + Home Manager Playbook

This repo now exposes both full NixOS hosts and standalone Home Manager profiles so you can bootstrap any Linux installation.

## NixOS host (`.#framework`)
1. Install NixOS normally and drop into the installed system.
2. Clone this repo to `~/.config/nix` and run `cp /etc/nixos/hardware-configuration.nix hosts/framework/` (or regenerate with `nixos-generate-config`).
3. Review `hosts/framework/configuration.nix` for host-only services, GPU drivers, etc.
4. Activate with `sudo nixos-rebuild switch --flake ~/.config/nix#framework` or `scripts/nixos-switch.sh`.

## Standalone Linux / WSL (`homeConfigurations`)
1. Install the [Nix installer](https://nixos.org/download.html#nix-install-linux) and Home Manager (`nix run nixpkgs#home-manager -- switch --flake ~/.config/nix#rex@wsl`).
2. `hosts/wsl/home.nix` sets the username/home path and imports the shared workstation profile; duplicate this file per machine as needed.
3. Run `./scripts/home-switch.sh` (optionally override `HOME_PROFILE` to target another profile) after editing dotfiles or modules.

### Tips
- Use `nix develop .#default --system x86_64-linux` to test Linux devShell changes from macOS.
- Keep secrets in Agenix; add each Linux host's SSH public key to `secrets/secrets.nix` so it can decrypt.
- `nix flake check --all-systems` evaluates the Linux hosts without requiring a builder.
